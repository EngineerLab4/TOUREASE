import SwiftUI
import SwiftData

struct ManageUsersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppUserRecord.joinedDate, order: .reverse) private var users: [AppUserRecord]

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 12) {
                    if users.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "person.2.slash").font(.system(size: 26)).foregroundStyle(Color.touroTextMuted)
                            Text("No users yet.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(Color.touroTextMuted)
                            Button("Load Demo Directory") { SampleUserSeed.seed(into: modelContext) }
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.touroTealLight)
                        }
                        .padding(.top, 60)
                    } else {
                        noticeBanner
                        ForEach(users) { user in
                            AdminUserRow(
                                user: user,
                                onToggleSuspend: { user.isSuspended.toggle(); try? modelContext.save() },
                                onDelete: { modelContext.delete(user); try? modelContext.save() }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Manage Users")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            if users.isEmpty { SampleUserSeed.seed(into: modelContext) }
        }
    }

    private var noticeBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill").foregroundStyle(Color.touroSunset)
            Text("Demo directory — connect Firebase to manage real app users.")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack { ManageUsersView() }
}
