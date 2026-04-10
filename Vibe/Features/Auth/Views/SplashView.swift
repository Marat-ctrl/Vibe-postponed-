import SwiftUI

struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var loaderWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                   VibeBackground()
               } else {
                   themeManager.current.background
                       .ignoresSafeArea()
               }
            
            VStack(spacing: 12) {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(hex: "#1A1A1A"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF6B9D").opacity(0.4),
                                            Color(hex: "#FF6B9D").opacity(0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                    
                    Text("V")
                        .font(.custom("Georgia-Italic", size: 38))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                Text("Vibe")
                    .font(.custom("Georgia-Italic", size: 38))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                
                Text("feel the moment")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(Color(hex: "#555555"))
                    .tracking(1)
                    .opacity(textOpacity)
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "#1F1F1F"))
                        .frame(width: 48, height: 2)
                    
                    Capsule()
                        .fill(Color(hex: "#FF6B9D"))
                        .frame(width: loaderWidth, height: 2)
                }
                .padding(.bottom, 60)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
                loaderWidth = 48
            }
        }
    }
}
