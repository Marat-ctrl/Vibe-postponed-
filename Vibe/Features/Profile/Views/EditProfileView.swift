import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct EditProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var bio = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            if themeManager.current.isVibe {
                VibeBackground()
            } else {
                themeManager.current.background
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                VibeNavBar(title: "редактировать", scrollOffset: 0) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
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
                
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(hex: "#1A1218"))
                            .frame(width: 88, height: 88)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(themeManager.current.accent.opacity(0.3), lineWidth: 0.5)
                            )
                        Text(String(username.prefix(1)).uppercased())
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(themeManager.current.accent)
                    }
                    .padding(.top, 24)
                    
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("имя пользователя")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                                .padding(.horizontal, 4)
                            
                            VibeTextField(placeholder: "username", text: $username)
                                .environmentObject(themeManager)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("о себе")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(themeManager.current.textSecondary)
                                .padding(.horizontal, 4)
                            
                            ZStack(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text("расскажи о себе...")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "#333333"))
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)
                                }
                                TextEditor(text: $bio)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .background(.clear)
                                    .frame(height: 100)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                            }
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
                    .padding(.horizontal, 24)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.current.accent)
                            .padding(.horizontal, 24)
                    }
                    
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("сохранить")
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
                    .disabled(isLoading || username.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            username = authVM.currentUser?.username ?? ""
            bio = authVM.currentUser?.bio ?? ""
        }
    }
    
    func saveProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let trimmedBio = bio.trimmingCharacters(in: .whitespaces)
        guard !trimmedUsername.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await Firestore.firestore().collection("users").document(uid).setData([
                "username": trimmedUsername,
                "bio": trimmedBio
            ], merge: true)
            await authVM.fetchCurrentUser()
            dismiss()
        } catch {
            errorMessage = "ошибка сохранения"
        }
        isLoading = false
    }
}
