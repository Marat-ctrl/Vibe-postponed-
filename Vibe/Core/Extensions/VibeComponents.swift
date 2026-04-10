import SwiftUI
import Combine 

struct VibeTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder)
            .foregroundColor(Color(hex: "#444444")))
            .font(.system(size: 15))
            .foregroundColor(.white)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#111111"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#1E1E1E"), lineWidth: 0.5)
                    )
            )
    }
}

struct VibeSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Group {
                if isVisible {
                    TextField("", text: $text, prompt: Text(placeholder)
                        .foregroundColor(Color(hex: "#444444")))
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder)
                        .foregroundColor(Color(hex: "#444444")))
                }
            }
            .font(.system(size: 15))
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#444444"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
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
