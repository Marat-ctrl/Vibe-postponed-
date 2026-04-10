import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case dark = "Dark"
    case vibe = "Vibe"
    
    var displayName: String { rawValue }
    
    var accent: Color {
        switch self {
        case .dark: return Color(hex: "#FF6B9D")
        case .vibe: return Color(hex: "#FF6B9D")
        }
    }
    
    var background: Color {
        switch self {
        case .dark: return Color(hex: "#0A0A0A")
        case .vibe: return Color(hex: "#0D0018")
        }
    }
    
    var surface: Color {
        switch self {
        case .dark: return Color(hex: "#111111")
        case .vibe: return Color(hex: "#ffffff").opacity(0.05)
        }
    }
    
    var surfaceBorder: Color {
        switch self {
        case .dark: return Color(hex: "#1E1E1E")
        case .vibe: return Color(hex: "#ffffff").opacity(0.08)
        }
    }
    
    var textPrimary: Color { .white }
    
    var textSecondary: Color {
        switch self {
        case .dark: return Color(hex: "#888888")
        case .vibe: return Color(hex: "#ffffff").opacity(0.45)
        }
    }
    
    var isVibe: Bool { self == .vibe }
}

class ThemeManager: ObservableObject {
    @Published var current: AppTheme {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "selectedTheme")
        }
    }
    
    static let shared = ThemeManager()
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "selectedTheme") ?? ""
        self.current = AppTheme(rawValue: saved) ?? .dark
    }
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
