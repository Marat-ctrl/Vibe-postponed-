import SwiftUI
import Combine 

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                   VibeBackground()
               } else {
                   themeManager.current.background
                       .ignoresSafeArea()
               }
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.current.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "#1A1A1A"))
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("создать аккаунт")
                        .font(.custom("Georgia-Italic", size: 28))
                        .foregroundColor(.white)
                    Text("присоединяйся к Vibe")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(themeManager.current.textSecondary)
                        .tracking(0.5)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                VStack(spacing: 12) {
                    VibeTextField(placeholder: "имя пользователя", text: $username)
                    VibeTextField(placeholder: "email", text: $email, keyboardType: .emailAddress)
                    VibeSecureField(placeholder: "пароль (мин. 6 символов)", text: $password)
                    
                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#FF6B9D"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    Button {
                        Task { await authVM.signUp(email: email, password: password, username: username) }
                    } label: {
                        ZStack {
                            if authVM.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("зарегистрироваться")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.current.accent)
                        )
                    }
                    .disabled(authVM.isLoading)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }
}
