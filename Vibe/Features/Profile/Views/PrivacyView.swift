import SwiftUI

struct PrivacyView: View {
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
                VibeNavBar(title: "конфиденциальность", scrollOffset: 0) {
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
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.current.accent)
                            
                            Text("ваши данные защищены")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(themeManager.current.textPrimary)
                        }
                        .padding(.top, 32)
                        
                        VStack(spacing: 12) {
                            privacyCard(
                                icon: "shield.lefthalf.filled",
                                title: "сквозное шифрование",
                                text: "все сообщения защищены сквозным шифрованием — никто кроме вас и собеседника не может их прочитать"
                            )
                            privacyCard(
                                icon: "person.badge.shield.checkmark.fill",
                                title: "защита аккаунта",
                                text: "ваши данные хранятся на серверах Firebase с соблюдением всех стандартов безопасности"
                            )
                            privacyCard(
                                icon: "eye.slash.fill",
                                title: "контроль данных",
                                text: "вы можете удалить аккаунт и все связанные данные в любой момент через поддержку"
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    func privacyCard(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(themeManager.current.accent)
                .frame(width: 28, height: 28)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.current.textPrimary)
                Text(text)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(themeManager.current.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(themeManager.current.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(themeManager.current.surfaceBorder, lineWidth: 0.5)
                )
        )
    }
}
