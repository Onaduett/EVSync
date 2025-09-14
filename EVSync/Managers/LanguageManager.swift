//
//  LanguageManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 08.09.25.
//

import SwiftUI
import Foundation

class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage = .english
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = "en"
    
    enum AppLanguage: String, CaseIterable {
        case english = "en"
        case kazakh = "kk"
        case russian = "ru"
        
        var name: String {
            switch self {
            case .english:
                return "English"
            case .kazakh:
                return "Қазақша"
            case .russian:
                return "Русский"
            }
        }
        
        var flag: String {
            switch self {
            case .english:
                return "🇺🇸"
            case .kazakh:
                return "🇰🇿"
            case .russian:
                return "🇷🇺"
            }
        }
        
        var shortName: String {
            switch self {
            case .english:
                return "EN"
            case .kazakh:
                return "KZ"
            case .russian:
                return "RU"
            }
        }
    }
    
    init() {
        if let language = AppLanguage(rawValue: selectedLanguageCode) {
            currentLanguage = language
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        selectedLanguageCode = language.rawValue
        
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func localizedString(_ key: String, comment: String = "") -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: comment)
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
