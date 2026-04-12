import SwiftUI
import Combine
import FirebaseAuth 

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
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
                Spacer()
                
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "#1A1A1A"))
                            .frame(width: 64, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                themeManager.current.accent.opacity(0.4),
                                                themeManager.current.accent.opacity(0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                        Text("V")
                            .font(.custom("Georgia-Italic", size: 28))
                            .foregroundColor(themeManager.current.textPrimary)
                    }
                    
                    Text("Vibe")
                        .font(.custom("Georgia-Italic", size: 32))
                        .foregroundColor(themeManager.current.textPrimary)
                    
                    Text("feel the moment")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(themeManager.current.textSecondary)
                        .tracking(1)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                VStack(spacing: 12) {
                    VStack(spacing: 10) {
                        VibeTextField(
                            placeholder: "email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        VibeSecureField(
                            placeholder: "пароль",
                            text: $password
                        )
                    }
                    
                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#FF6B9D"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    Button {
                        Task { await authVM.signIn(email: email, password: password) }
                    } label: {
                        ZStack {
                            if authVM.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("войти")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.current.textPrimary)
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
                    
                    Button {
                        showSignUp = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("нет аккаунта?")
                                .foregroundColor(themeManager.current.textSecondary)
                            Text("зарегистрироваться")
                                .foregroundColor(themeManager.current.accent)
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authVM)
                .environmentObject(themeManager)
        }
    }
}
