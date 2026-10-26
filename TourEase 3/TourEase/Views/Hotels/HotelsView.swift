import SwiftUI
import SwiftData

struct HotelsView: View {
    @State private var vm = HotelsViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteHotel.savedDate, order: .reverse) private var favorites: [FavoriteHotel]

    private var favoriteIDs: Set<String> { Set(favorites.map(\.id)) }

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 18) {
                    searchCard

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.touroSunset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }

                    if vm.isSearching {
                        SkeletonResultList().padding(.horizontal, 20)
                    } else if !vm.hotels.isEmpty {
                        filterCard

                        LazyVStack(spacing: 12) {
                            ForEach(vm.displayedHotels) { hotel in
                                HotelCard(
                                    hotel: hotel,
                                    isFavorite: favoriteIDs.contains(hotel.id),
                                    onToggleFavorite: { toggleFavorite(hotel) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.25), value: vm.sortOption)
                        .animation(.easeInOut(duration: 0.25), value: vm.categoryFilter)

                        if vm.displayedHotels.isEmpty {
                            Text("No hotels match this filter.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(Color.touroTextMuted)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Hotels")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var searchCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                LocationSearchField(
                    title: "Search destination",
                    systemImage: "mappin.circle.fill",
                    text: $vm.destinationQuery,
                    suggestions: vm.suggestions,
                    onTextChanged: { vm.updateQuery($0) },
                    onSelectSuggestion: { vm.selectSuggestion($0) }
                )

                PrimaryButton(title: "Find Hotels", isLoading: vm.isSearching) {
                    Task {
                        await vm.search()
                        SearchHistoryLogger.log(query: vm.destinationQuery, category: .hotel, context: modelContext)
                    }
                }
                .opacity(vm.destinationQuery.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .disabled(vm.destinationQuery.trimmingCharacters(in: .whitespaces).isEmpty || vm.isSearching)
            }
        }
        .padding(.horizontal, 20)
    }

    private var filterCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                FloatingTextField(title: "Filter by name", systemImage: "magnifyingglass", text: $vm.nameFilter)
                PillSegmentedControl(title: "Category", selection: $vm.categoryFilter)
                PillSegmentedControl(title: "Sort by", selection: $vm.sortOption)
            }
        }
        .padding(.horizontal, 20)
    }

    private func toggleFavorite(_ hotel: Hotel) {
        if let existing = favorites.first(where: { $0.id == hotel.id }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteHotel(hotel: hotel))
        }
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack { HotelsView() }
}
