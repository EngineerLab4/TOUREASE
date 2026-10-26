import SwiftUI
import SwiftData

private enum HistorySection: String, CaseIterable, Identifiable {
    case routes, budgets, hotels, searches, preferences
    var id: String { rawValue }
    var label: String {
        switch self {
        case .routes: return "Routes"
        case .budgets: return "Budgets"
        case .hotels: return "Hotels"
        case .searches: return "Searches"
        case .preferences: return "Preferences"
        }
    }
}

struct HistoryView: View {
    @State private var section: HistorySection = .routes
    @Namespace private var tabNamespace
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \RecentRouteRecord.timestamp, order: .reverse) private var routes: [RecentRouteRecord]
    @Query(sort: \BudgetRecord.createdDate, order: .reverse) private var budgets: [BudgetRecord]
    @Query(sort: \FavoriteHotel.savedDate, order: .reverse) private var favoriteHotels: [FavoriteHotel]
    @Query(sort: \SearchHistoryRecord.timestamp, order: .reverse) private var searchLog: [SearchHistoryRecord]
    @Query private var preferencesRecords: [UserPreferencesRecord]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 14) {
                tabRow
                    .padding(.top, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        switch section {
                        case .routes: routesSection
                        case .budgets: budgetsSection
                        case .hotels: hotelsSection
                        case .searches: searchesSection
                        case .preferences: preferencesSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var tabRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HistorySection.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) { section = tab }
                    } label: {
                        Text(tab.label)
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(section == tab ? .white : Color.touroTextMuted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background {
                                if section == tab {
                                    Capsule()
                                        .fill(LinearGradient.touroCTA)
                                        .matchedGeometryEffect(id: "tab", in: tabNamespace)
                                } else {
                                    Capsule().fill(Color.white.opacity(0.06))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Sections

    @ViewBuilder private var routesSection: some View {
        if routes.isEmpty {
            emptyState(icon: "point.topleft.down.curvedto.point.bottomright.up.fill", text: "No routes planned yet. Try Route Planner from the dashboard.")
        } else {
            ForEach(routes) { route in
                RecentRouteRow(route: route)
                    .contextDelete { modelContext.delete(route); try? modelContext.save() }
            }
        }
    }

    @ViewBuilder private var budgetsSection: some View {
        if budgets.isEmpty {
            emptyState(icon: "indianrupeesign.circle.fill", text: "No saved budgets yet. Try Budget Planner from the dashboard.")
        } else {
            ForEach(budgets) { budget in
                BudgetHistoryRow(budget: budget)
                    .contextDelete { modelContext.delete(budget); try? modelContext.save() }
            }
        }
    }

    @ViewBuilder private var hotelsSection: some View {
        if favoriteHotels.isEmpty {
            emptyState(icon: "heart.fill", text: "No favourite hotels yet. Tap the heart on any hotel to save it here.")
        } else {
            ForEach(favoriteHotels) { hotel in
                FavoriteHotelRow(hotel: hotel)
                    .contextDelete { modelContext.delete(hotel); try? modelContext.save() }
            }
        }
    }

    @ViewBuilder private var searchesSection: some View {
        if searchLog.isEmpty {
            emptyState(icon: "magnifyingglass", text: "No searches yet. Hotels, Food, Nearby Places, and Weather searches show up here.")
        } else {
            HStack {
                Spacer()
                Button("Clear All") {
                    searchLog.forEach { modelContext.delete($0) }
                    try? modelContext.save()
                }
                .font(.system(size: 12.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color.touroSunset)
            }
            ForEach(searchLog.prefix(50)) { entry in
                SearchHistoryRow(entry: entry)
            }
        }
    }

    @ViewBuilder private var preferencesSection: some View {
        PreferencesEditor(existing: preferencesRecords.first)
    }

    private func emptyState(icon: String, text: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 26)).foregroundStyle(Color.touroTextMuted)
            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.top, 40)
    }
}

/// Small helper modifier so every history row gets the same swipe-to-delete
/// affordance without repeating `.swipeActions` setup per section.
private extension View {
    /// Long-press any row to delete it (not a `List`, so `.swipeActions`
    /// isn't available — `.contextMenu` is the right equivalent here).
    func contextDelete(action: @escaping () -> Void) -> some View {
        self.contextMenu {
            Button(role: .destructive, action: action) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

/// Preferences tab — creates the single `UserPreferencesRecord` on first
/// save, updates it thereafter.
private struct PreferencesEditor: View {
    let existing: UserPreferencesRecord?
    @Environment(\.modelContext) private var modelContext

    @State private var hotelCategory: HotelCategory = .standard
    @State private var foodPreference: FoodPreference = .standardDining
    @State private var defaultTripDays: Int = 3
    @State private var didSave = false

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("Default Preferences")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PillSegmentedControl(title: "Preferred Hotel Category", selection: $hotelCategory)
                PillSegmentedControl(title: "Preferred Food", selection: $foodPreference)

                HStack {
                    Text("Default Trip Days")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.touroTextPrimary)
                    Spacer()
                    Text("\(defaultTripDays)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Stepper("", value: $defaultTripDays, in: 1...30).labelsHidden().tint(.touroTeal)
                }

                if didSave {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.touroTealLight)
                        Text("Preferences saved").font(.system(size: 12.5, design: .rounded)).foregroundStyle(Color.touroTealLight)
                    }
                }

                PrimaryButton(title: "Save Preferences") { save() }
            }
        }
        .onAppear {
            if let existing {
                hotelCategory = existing.preferredHotelCategory
                foodPreference = existing.preferredFoodPreference
                defaultTripDays = existing.defaultTripDays
            }
        }
    }

    private func save() {
        if let existing {
            existing.preferredHotelCategoryRaw = hotelCategory.rawValue
            existing.preferredFoodPreferenceRaw = foodPreference.rawValue
            existing.defaultTripDays = defaultTripDays
            existing.updatedDate = .now
        } else {
            modelContext.insert(UserPreferencesRecord(hotelCategory: hotelCategory, foodPreference: foodPreference, defaultTripDays: defaultTripDays))
        }
        try? modelContext.save()
        withAnimation { didSave = true }
    }
}

#Preview {
    NavigationStack { HistoryView() }
}
