import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case dark = "Dark"
    case vibe = "Vibe"
    case white = "White"
    case aqua = "Aqua"
    
    var displayName: String { rawValue }
    
    var isLight: Bool { self == .white || self == .aqua }
    var isVibe: Bool { self == .vibe }
    
    var accent: Color {
        switch self {
        case .dark: return Color(hex: "#FF6B9D")
        case .vibe: return Color(hex: "#FF6B9D")
        case .white: return Color(hex: "#00B4D8")
        case .aqua: return Color(hex: "#00B4D8")
        }
    }
    
    var background: Color {
        switch self {
        case .dark: return Color(hex: "#0A0A0A")
        case .vibe: return Color(hex: "#0D0018")
        case .white: return Color(hex: "#F5F7FA")
        case .aqua: return Color(hex: "#F5F7FA")
        }
    }
    
    var surface: Color {
        switch self {
        case .dark: return Color(hex: "#111111")
        case .vibe: return Color(hex: "#ffffff").opacity(0.05)
        case .white: return Color(hex: "#FFFFFF")
        case .aqua: return Color(hex: "#FFFFFF")
        }
    }
    
    var surfaceBorder: Color {
        switch self {
        case .dark: return Color(hex: "#1E1E1E")
        case .vibe: return Color(hex: "#ffffff").opacity(0.08)
        case .white: return Color(hex: "#E2E8F0")
        case .aqua: return Color(hex: "#00B4D8").opacity(0.2)
        }
    }
    
    var textPrimary: Color {
        switch self {
        case .dark, .vibe: return .white
        case .white, .aqua: return Color(hex: "#1A1A2E")
        }
    }
    
    var textSecondary: Color {
        switch self {
        case .dark: return Color(hex: "#888888")
        case .vibe: return Color(hex: "#ffffff").opacity(0.45)
        case .white: return Color(hex: "#718096")
        case .aqua: return Color(hex: "#718096")
        }
    }
    
    var colorScheme: ColorScheme {
        isLight ? .light : .dark
    }
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
