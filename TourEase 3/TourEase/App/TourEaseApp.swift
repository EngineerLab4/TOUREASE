import SwiftUI
import SwiftData
import FirebaseCore

@main
struct TourEaseApp: App {
    private let sessionManager = SessionManager()
    private let authViewModel: AuthViewModel

    let modelContainer: ModelContainer

    init() {
        FirebaseApp.configure()
        
        do {
            modelContainer = try ModelContainer(for: SessionRecord.self, AdBanner.self, BudgetRecord.self, FavoriteHotel.self, SearchHistoryRecord.self, RecentRouteRecord.self, UserPreferencesRecord.self, UserProfileRecord.self, AppUserRecord.self)
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }
        let service: AuthServicing = FirebaseAuthService()
        self.authViewModel = AuthViewModel(authService: service, sessionManager: sessionManager)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sessionManager)
                .environment(authViewModel)
                .modelContainer(modelContainer)
                .onAppear {
                    sessionManager.attach(context: modelContainer.mainContext)
                }
        }
    }
}
