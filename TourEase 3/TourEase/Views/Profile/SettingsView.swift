import SwiftUI
import SwiftData

struct SettingsView: View {
    let userID: String
    @Environment(\.modelContext) private var modelContext

    @Query private var profileRecords: [UserProfileRecord]
    @Query private var budgets: [BudgetRecord]
    @Query private var favorites: [FavoriteHotel]
    @Query private var searchLog: [SearchHistoryRecord]
    @Query private var routes: [RecentRouteRecord]

    @State private var notificationsEnabled = true
    @State private var showClearConfirmation = false
    @State private var didClear = false

    private var myProfile: UserProfileRecord? { profileRecords.first { $0.id == userID } }

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 18) {
                    GlassCard {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack(spacing: 10) {
                                Image(systemName: "bell.fill").foregroundStyle(Color.touroTealLight)
                                Text("Notifications")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(Color.touroTextPrimary)
                            }
                        }
                        .tint(.touroTeal)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            persistNotificationSetting(newValue)
                        }
                    }
                    .padding(.horizontal, 20)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Local Data")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("\(budgets.count) saved budgets · \(favorites.count) favourite hotels · \(routes.count) routes · \(searchLog.count) searches")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(Color.touroTextMuted)

                            if didClear {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.touroTealLight)
                                    Text("Local data cleared").font(.system(size: 12.5, design: .rounded)).foregroundStyle(Color.touroTealLight)
                                }
                            }

                            PrimaryButton(title: "Clear Local Data", gradient: .touroAccentCTA) {
                                showClearConfirmation = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    GlassCard {
                        VStack(spacing: 8) {
                            Text("TourEase")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Version \(appVersion) (\(buildNumber))")
                                .font(.system(size: 11.5, design: .rounded))
                                .foregroundStyle(Color.touroTextMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            notificationsEnabled = myProfile?.notificationsEnabled ?? true
        }
        .alert("Clear all local data?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) { clearLocalData() }
        } message: {
            Text("This removes saved budgets, favourite hotels, routes, and search history from this device. This can't be undone.")
        }
    }

    private func persistNotificationSetting(_ enabled: Bool) {
        if let existing = myProfile {
            existing.notificationsEnabled = enabled
            existing.updatedDate = .now
        } else {
            let record = UserProfileRecord(userID: userID, displayName: "")
            record.notificationsEnabled = enabled
            modelContext.insert(record)
        }
        try? modelContext.save()
    }

    private func clearLocalData() {
        budgets.forEach { modelContext.delete($0) }
        favorites.forEach { modelContext.delete($0) }
        searchLog.forEach { modelContext.delete($0) }
        routes.forEach { modelContext.delete($0) }
        try? modelContext.save()
        withAnimation { didClear = true }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    NavigationStack { SettingsView(userID: "preview-user") }
}
