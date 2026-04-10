import SwiftUI

struct VibeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#1a0030"),
                Color(hex: "#0D0018"),
                Color(hex: "#0D0018"),
                Color(hex: "#1a0020")
            ],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}
