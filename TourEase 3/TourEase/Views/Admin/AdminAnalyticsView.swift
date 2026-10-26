import SwiftUI
import SwiftData
import Charts

/// Every number here is a real `@Query` count over this device's SwiftData
/// store — not fabricated analytics. A production build would replace
/// these with aggregated Firestore queries across all users (same
/// real-data-only principle as everywhere else in the app); until then,
/// this honestly reflects local trip activity rather than inventing
/// platform-wide figures no backend actually provides yet.
struct AdminAnalyticsView: View {
    @Query private var routes: [RecentRouteRecord]
    @Query private var budgets: [BudgetRecord]
    @Query private var favorites: [FavoriteHotel]
    @Query private var searchLog: [SearchHistoryRecord]
    @Query private var users: [AppUserRecord]

    private var totalBudgetValue: Double { budgets.reduce(0) { $0 + $1.totalCost } }
    private var averageTripDays: Double {
        guard !budgets.isEmpty else { return 0 }
        return Double(budgets.reduce(0) { $0 + $1.tripDays }) / Double(budgets.count)
    }

    private var searchesByCategory: [(String, Int)] {
        Dictionary(grouping: searchLog, by: { $0.category.displayName })
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Trip Statistics (this device)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                    statsGrid

                    if !searchesByCategory.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Searches by Module")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                Chart(searchesByCategory, id: \.0) { entry in
                                    BarMark(x: .value("Count", entry.1), y: .value("Module", entry.0))
                                        .foregroundStyle(LinearGradient.touroCTA)
                                        .cornerRadius(4)
                                }
                                .frame(height: CGFloat(searchesByCategory.count) * 36 + 20)
                                .chartXAxis { AxisMarks(position: .bottom) }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statTile(icon: "point.topleft.down.curvedto.point.bottomright.up.fill", label: "Routes Planned", value: "\(routes.count)")
            statTile(icon: "indianrupeesign.circle.fill", label: "Budgets Saved", value: "\(budgets.count)")
            statTile(icon: "heart.fill", label: "Favourite Hotels", value: "\(favorites.count)")
            statTile(icon: "person.2.fill", label: "Directory Users", value: "\(users.count)")
            statTile(icon: "calendar", label: "Avg Trip Days", value: String(format: "%.1f", averageTripDays))
            statTile(icon: "banknote.fill", label: "Total Budgeted", value: "₹\(Int(totalBudgetValue.rounded()))")
        }
        .padding(.horizontal, 20)
    }

    private func statTile(icon: String, label: String, value: String) -> some View {
        GlassCard {
            VStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(Color.touroTealLight)
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    NavigationStack { AdminAnalyticsView() }
}
