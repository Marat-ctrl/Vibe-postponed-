import SwiftUI

struct HelpView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                VibeBackground()
            } else {
                themeManager.current.background
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                VibeNavBar(title: "помощь", scrollOffset: 0) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.current.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(themeManager.current.surface)
                                    .overlay(Circle().stroke(themeManager.current.surfaceBorder, lineWidth: 0.5))
                            )
                    }
                }
                .environmentObject(themeManager)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 16) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.current.accent)
                            
                            Text("мы здесь чтобы помочь")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(themeManager.current.textPrimary)
                            
                            Text("если у вас возникли вопросы или проблемы — напишите нам")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 32)
                        
                        Button {
                            if let url = URL(string: "mailto:support@vibe-app.io") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(themeManager.current.accent)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("написать в поддержку")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                    Text("support@vibe-app.io")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(themeManager.current.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.current.textSecondary.opacity(0.4))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(themeManager.current.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("версия приложения")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                            Text("Vibe 1.0.0")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.current.textSecondary.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
