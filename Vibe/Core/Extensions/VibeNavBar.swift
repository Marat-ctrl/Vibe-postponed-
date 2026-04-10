import SwiftUI

struct VibeNavBar<TrailingContent: View>: View {
    let title: String
    let isLogo: Bool
    let scrollOffset: CGFloat
    @EnvironmentObject var themeManager: ThemeManager
    @ViewBuilder let trailing: TrailingContent
    
    init(title: String, isLogo: Bool = false, scrollOffset: CGFloat = 0, @ViewBuilder trailing: () -> TrailingContent) {
        self.title = title
        self.isLogo = isLogo
        self.scrollOffset = scrollOffset
        self.trailing = trailing()
    }
    
    var isVisible: Bool { scrollOffset > -40 }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                if isLogo {
                    Text("Vibe")
                        .font(.custom("Georgia-Italic", size: 24))
                        .foregroundColor(.white)
                } else {
                    Text(title)
                        .font(.custom("Georgia-Italic", size: 22))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                trailing
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    themeManager.current.background,
                    themeManager.current.background,
                    themeManager.current.background.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .animation(.easeInOut(duration: 0.2), value: isVisible)
    }
}

extension VibeNavBar where TrailingContent == EmptyView {
    init(title: String, isLogo: Bool = false, scrollOffset: CGFloat = 0) {
        self.title = title
        self.isLogo = isLogo
        self.scrollOffset = scrollOffset
        self.trailing = EmptyView()
    }
}
