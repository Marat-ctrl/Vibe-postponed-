import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var users: [VUser] = []
    @Published var searchText = ""
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { await self?.searchUsers(query: text) }
            }
            .store(in: &cancellables)
    }
    
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            users = []
            return
        }
        isLoading = true
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        
        let snapshot = try? await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThan: query + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        
        users = snapshot?.documents.compactMap { doc -> VUser? in
            guard doc.documentID != currentUserId else { return nil }
            let data = doc.data()
            return VUser(
                id: doc.documentID,
                username: data["username"] as? String ?? "",
                displayName: data["displayName"] as? String ?? ""
            )
        } ?? []
        isLoading = false
    }
}
