import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentUser: VUser?
   
    
    private var userListener: ListenerRegistration?
    
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task { await fetchCurrentUser() }
    }
    
    func fetchCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        startListeningToCurrentUser(uid: uid)
    }
    
    func startListeningToCurrentUser(uid: String) {
        userListener?.remove()
        userListener = Firestore.firestore().collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let data = snapshot?.data() else { return }
                var u = VUser(
                    id: uid,
                    username: data["username"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? ""
                )
                u.followersCount = data["followersCount"] as? Int ?? 0
                u.followingCount = data["followingCount"] as? Int ?? 0
                u.bio = data["bio"] as? String ?? ""
                u.postsCount = data["postsCount"] as? Int ?? 0
                self.currentUser = u
            }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            startListeningToCurrentUser(uid: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func isUsernameAvailable(_ username: String) async -> Bool {
        let snapshot = try? await Firestore.firestore()
            .collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()
        return snapshot?.documents.isEmpty ?? true
    }

    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = ""
        
        let cleanUsername = username.lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "@", with: "")
        
        guard cleanUsername.count >= 3 else {
            errorMessage = "имя пользователя минимум 3 символа"
            isLoading = false
            return
        }
        
        let available = await isUsernameAvailable(cleanUsername)
        guard available else {
            errorMessage = "@\(cleanUsername) уже занят"
            isLoading = false
            return
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            await saveUserToFirestore(uid: result.user.uid, email: email, username: cleanUsername)
            startListeningToCurrentUser(uid: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signOut() {
        userListener?.remove()
        userListener = nil
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
    }
    
    private func saveUserToFirestore(uid: String, email: String, username: String) async {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "id": uid,
            "username": username,
            "displayName": username,
            "bio": "",
            "avatarURL": "",
            "followersCount": 0,
            "followingCount": 0,
            "createdAt": Timestamp(date: Date())
        ]
        try? await db.collection("users").document(uid).setData(userData)
    }
}
