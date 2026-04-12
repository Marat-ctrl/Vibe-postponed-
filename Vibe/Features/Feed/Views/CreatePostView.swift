import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var feedVM: FeedViewModel
    let username: String
    @State private var text = ""
    @State private var isPosting = false
    
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
                    
                    Button {
                        Task {
                            isPosting = true
                            await feedVM.createPost(text: text, authorUsername: username)
                            isPosting = false
                            dismiss()
                        }
                    } label: {
                        if isPosting {
                            ProgressView().tint(.white)
                                .frame(width: 80, height: 36)
                        } else {
                            Text("опубликовать")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .frame(height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color(hex: "#1A1A1A") : themeManager.current.accent)
                                )
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#1A1218"))
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.current.accent.opacity(0.2), lineWidth: 0.5)
                            )
                        Text(String(username.prefix(1)).uppercased())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.current.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(username)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("что происходит?")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(Color(hex: "#333333"))
                                    .padding(.top, 8)
                            }
                            TextEditor(text: $text)
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(Color(hex: "#CCCCCC"))
                                .scrollContentBackground(.hidden)
                                .background(.clear)
                                .frame(minHeight: 120)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("\(280 - text.count)")
                        .font(.system(size: 13))
                        .foregroundColor(text.count > 260 ? Color(hex: "#FF6B9D") : themeManager.current.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            
            .hideKeyboardOnTap()
            .navigationBarHidden(true)
            
        }
    }
}
