import SwiftUI
import SwiftData

struct FoodView: View {
    @State private var vm = FoodViewModel()
    @Environment(\.modelContext) private var modelContext

    private let gridColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 18) {
                    summaryCard
                    averagesRow
                    searchCard

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.touroSunset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }

                    if !vm.places.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.places) { place in
                                FoodPlaceCard(place: place)
                            }
                        }
                        .padding(.horizontal, 20)
                    } else if vm.isSearching {
                        SkeletonResultList().padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Food")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var summaryCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("Cost Averages")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(FoodCategory.allCases) { category in
                        FoodCostCard(category: category, amount: vm.averageCost(category))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var averagesRow: some View {
        HStack(spacing: 12) {
            averageTile(title: "Daily Average", amount: vm.dailyAverage, icon: "sun.max.fill")
            averageTile(title: "Weekly Average", amount: vm.weeklyAverage, icon: "calendar")
        }
        .padding(.horizontal, 20)
    }

    private func averageTile(title: String, amount: Double, icon: String) -> some View {
        GlassCard {
            VStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(Color.touroSunset)
                Text(title)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                Text("₹\(Int(amount.rounded()))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var searchCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                Text("Find Restaurants & Cafes")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LocationSearchField(
                    title: "Search destination",
                    systemImage: "mappin.circle.fill",
                    text: $vm.destinationQuery,
                    suggestions: vm.suggestions,
                    onTextChanged: { vm.updateQuery($0) },
                    onSelectSuggestion: { vm.selectSuggestion($0) }
                )

                PrimaryButton(title: "Search Nearby", isLoading: vm.isSearching) {
                    Task {
                        await vm.search()
                        SearchHistoryLogger.log(query: vm.destinationQuery, category: .food, context: modelContext)
                    }
                }
                .opacity(vm.destinationQuery.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .disabled(vm.destinationQuery.trimmingCharacters(in: .whitespaces).isEmpty || vm.isSearching)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack { FoodView() }
}
