//
//  CarComponents.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct SpecificationItem: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    let languageManager: LanguageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 16)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 0)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ChargingTimeEstimate: View {
    let power: Int
    let time: String
    let type: String
    @ObservedObject private var languageManager = LanguageManager()
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(power) \(languageManager.localizedString("kw_unit"))")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(time)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(type)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(radius: 4, x: 0, y: 2)
        )
    }
}

struct ChargingSessionRow: View {
    let session: ChargingSession
    @ObservedObject private var languageManager = LanguageManager()
    
    var body: some View {
        HStack(spacing: 12) {
            // Date and time
            VStack(alignment: .leading, spacing: 2) {
                Text(session.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(session.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Location
            VStack(alignment: .trailing, spacing: 2) {
                Text(session.location)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(String(format: "%.1f", session.energyAdded)) \(languageManager.localizedString("kwh_unit"))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Cost
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(session.cost)) ₸")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(session.chargingSpeed) \(languageManager.localizedString("kw_unit"))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct EnvironmentalStat: View {
    let icon: String
    let title: String
    let value: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.1))
        )
    }
}