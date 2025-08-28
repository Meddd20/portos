//
//  Color+Extensions.swift
//  portos
//
//  Created by Niki Hidayati on 25/08/25.
//

import Foundation
import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primaryApp = Color(light: Color(red: 0.21, green: 0.11, blue: 0), 
                                 dark: Color(red: 0.85, green: 0.75, blue: 0.65)) // brown -> warm beige
    
    static let secondaryApp = Color(light: Color(red: 0.77, green: 0.71, blue: 0.62), 
                                   dark: Color(red: 0.45, green: 0.39, blue: 0.30)) // light brown -> darker brown
    
    // MARK: - Background Colors
    static let backgroundApp = Color(light: Color(red: 0.98, green: 0.98, blue: 0.96), 
                                    dark: Color(red: 0.08, green: 0.08, blue: 0.10)) // off-white -> dark gray
    
    // MARK: - Text Colors
    static let textPlaceholderApp = Color(light: Color(red: 0.57, green: 0.57, blue: 0.57), 
                                         dark: Color(red: 0.65, green: 0.65, blue: 0.67)) // gray -> lighter gray
    
    // MARK: - Neutral Colors
    static let greyApp = Color(light: Color(red: 0.84, green: 0.84, blue: 0.84), 
                              dark: Color(red: 0.25, green: 0.25, blue: 0.27)) // light gray -> dark gray
    
    // MARK: - Success Colors
    static let greenApp = Color(light: Color(red: 0.05, green: 0.6, blue: 0.11), 
                               dark: Color(red: 0.20, green: 0.75, blue: 0.26)) // green -> brighter green
    
    static let greenAppLight = Color(light: Color(red: 0.86, green: 0.92, blue: 0.86), 
                                    dark: Color(red: 0.15, green: 0.35, blue: 0.18)) // light green -> dark green
    
    // MARK: - Error Colors
    static let redApp = Color(light: Color(red: 0.8, green: 0.14, blue: 0.15), 
                             dark: Color(red: 0.95, green: 0.29, blue: 0.30)) // red -> brighter red
    
    static let redAppLight = Color(light: Color(red: 0.95, green: 0.9, blue: 0.9), 
                                  dark: Color(red: 0.35, green: 0.15, blue: 0.16)) // light red -> dark red
    
    // MARK: - Common UI Colors
    static let textPrimary = Color(light: .black, dark: .white) // Primary text color
    static let textSecondary = Color(light: Color(red: 0.3, green: 0.3, blue: 0.3), 
                                    dark: Color(red: 0.8, green: 0.8, blue: 0.8)) // Secondary text color
    static let textTertiary = Color(light: Color(red: 0.5, green: 0.5, blue: 0.5), 
                                   dark: Color(red: 0.6, green: 0.6, blue: 0.6)) // Tertiary text color
    
    static let backgroundPrimary = Color(light: .white, dark: Color(red: 0.12, green: 0.12, blue: 0.14)) // Primary background
    static let backgroundSecondary = Color(light: Color(red: 0.96, green: 0.96, blue: 0.96), 
                                          dark: Color(red: 0.18, green: 0.18, blue: 0.20)) // Secondary background
    
    static let borderColor = Color(light: Color(red: 0.9, green: 0.9, blue: 0.9), 
                                  dark: Color(red: 0.3, green: 0.3, blue: 0.3)) // Border color
    static let shadowColor = Color(light: .black.opacity(0.06), 
                                  dark: .black.opacity(0.3)) // Shadow color
    
    // MARK: - CTA (Buttons)
    // Enabled background: keep strong brand on light, slightly darker warm tone on dark for better contrast
    static let ctaEnabledBackground = Color(
        light: Color(red: 0.21, green: 0.11, blue: 0.0),
        dark: Color(red: 0.45, green: 0.39, blue: 0.30)
    )
    // Disabled background: subtle neutral in both modes
    static let ctaDisabledBackground = Color(
        light: Color(red: 0.90, green: 0.90, blue: 0.90),
        dark: Color(red: 0.25, green: 0.25, blue: 0.27)
    )
    // Text on enabled CTA: white on light, near-black on dark for contrast on warm beige
    static let ctaEnabledText = Color(light: .white, dark: Color(red: 0.05, green: 0.05, blue: 0.06))
}

// MARK: - Dark Mode Support
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
