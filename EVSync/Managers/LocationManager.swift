//
//  LocationManager.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 14.09.25.
//

import SwiftUI
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    @Published var locationError: LocationError?
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    enum LocationError: Error, LocalizedError {
        case servicesDisabled
        case accessDenied
        case locationUnknown
        case restricted
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .servicesDisabled:
                return "Location services are disabled"
            case .accessDenied:
                return "Location access denied"
            case .locationUnknown:
                return "Unable to determine location"
            case .restricted:
                return "Location access restricted"
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }
    
    override init() {
        super.init()
        setupLocationManager()
        loadLocationPreference()
    }
    
    // MARK: - Public Methods
    
    func requestLocationPermission() {
        print("Requesting location permission. Current status: \(locationManager.authorizationStatus.rawValue)")
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied or restricted")
            locationError = authorizationStatus == .denied ? .accessDenied : .restricted
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        print("Starting location updates. Authorization status: \(authorizationStatus.rawValue)")
        
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            print("Location not authorized, requesting permission")
            requestLocationPermission()
            return
        }
        
        // Move the location services check to a background queue to avoid main thread warning
        DispatchQueue.global(qos: .userInitiated).async {
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            
            DispatchQueue.main.async {
                guard servicesEnabled else {
                    print("Location services not enabled")
                    self.locationError = .servicesDisabled
                    return
                }
                
                self.locationManager.startUpdatingLocation()
                self.isLocationEnabled = true
                print("Location updates started")
            }
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        userLocation = nil
        isLocationEnabled = false
        print("Location updates stopped and user location cleared")
    }
    
    func enableLocation() {
        isLocationEnabled = true
        saveLocationPreference()
        requestLocationPermission()
    }
    
    func disableLocation() {
        isLocationEnabled = false
        saveLocationPreference()
        stopLocationUpdates()
    }
    
    func openLocationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Location Alert Types
    
    enum LocationAlertType {
        case disabled
        case denied
        case restricted
        case servicesDisabled
        
        var title: String {
            let languageManager = LanguageManager()
            switch self {
            case .disabled:
                return languageManager.localizedString("location_disabled_title")
            case .denied, .restricted:
                return languageManager.localizedString("location_access_title")
            case .servicesDisabled:
                return languageManager.localizedString("location_services_disabled_title")
            }
        }
        
        var message: String {
            let languageManager = LanguageManager()
            switch self {
            case .disabled:
                return languageManager.localizedString("location_disabled_message")
            case .denied, .restricted:
                return languageManager.localizedString("location_access_denied_message")
            case .servicesDisabled:
                return languageManager.localizedString("location_services_disabled_message")
            }
        }
        
        var buttonTitle: String {
            let languageManager = LanguageManager()
            switch self {
            case .disabled:
                return languageManager.localizedString("enable")
            case .denied, .restricted, .servicesDisabled:
                return languageManager.localizedString("open_settings")
            }
        }
    }
    
    func getLocationAlertType() -> LocationAlertType? {
        if !isLocationEnabled {
            return .disabled
        }
        
        switch authorizationStatus {
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined, .authorizedWhenInUse, .authorizedAlways:
            if let error = locationError, case .servicesDisabled = error {
                return .servicesDisabled
            }
            return nil
        @unknown default:
            return nil
        }
    }
    
    func handleLocationAlert(type: LocationAlertType) {
        switch type {
        case .disabled:
            enableLocation()
        case .denied, .restricted, .servicesDisabled:
            openLocationSettings()
        }
    }
    
    // MARK: - Location Button States
    
    var locationButtonIcon: String {
        if !isLocationEnabled {
            return "location.slash"
        } else if userLocation != nil {
            return "location.fill"
        } else {
            return "location"
        }
    }
    
    func locationButtonColor(colorScheme: ColorScheme) -> Color {
        if !isLocationEnabled {
            return .gray
        } else if userLocation != nil {
            return .blue
        } else {
            return colorScheme == .dark ? .white : .black
        }
    }
    
    var locationBorderColor: Color {
        if !isLocationEnabled {
            return .clear
        } else if userLocation != nil {
            return .blue.opacity(0.3)
        } else {
            return .clear
        }
    }
    
    var locationBorderWidth: CGFloat {
        (userLocation != nil && isLocationEnabled) ? 1.5 : 0
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    private func loadLocationPreference() {
        isLocationEnabled = UserDefaults.standard.bool(forKey: "locationEnabled")
    }
    
    private func saveLocationPreference() {
        UserDefaults.standard.set(isLocationEnabled, forKey: "locationEnabled")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.userLocation = location.coordinate
            self.locationError = nil
        }
        
        // Stop updating after getting first location to save battery
        manager.stopUpdatingLocation()
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if self.isLocationEnabled {
                    self.startLocationUpdates()
                }
            case .denied:
                self.locationError = .accessDenied
                self.stopLocationUpdates()
            case .restricted:
                self.locationError = .restricted
                self.stopLocationUpdates()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .locationUnknown:
                    self.locationError = .locationUnknown
                case .denied:
                    self.locationError = .accessDenied
                default:
                    self.locationError = .unknown(error)
                }
            } else {
                self.locationError = .unknown(error)
            }
        }
    }
}
