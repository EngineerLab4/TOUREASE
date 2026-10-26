import SwiftUI
import SwiftData

struct NearbyPlacesView: View {
    @State private var locationManager = LocationManager()
    @State private var vm: NearbyPlacesViewModel
    @Environment(\.modelContext) private var modelContext

    init() {
        let manager = LocationManager()
        _locationManager = State(initialValue: manager)
        _vm = State(initialValue: NearbyPlacesViewModel(locationManager: manager))
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 16) {
                searchCard
                    .padding(.top, 8)

                NearbyCategoryChipRow(selection: vm.selectedCategory) { category in
                    vm.selectCategory(category)
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.touroSunset)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                }

                if vm.isSearching {
                    ScrollView {
                        SkeletonResultList().padding(.horizontal, 20).padding(.top, 8)
                    }
                } else if vm.places.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "mappin.slash")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.touroTextMuted)
                        Text("Search a destination or use your current location to see nearby places.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.places) { place in
                                NearbyPlaceCard(place: place)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle("Nearby Places")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { locationManager.requestPermission() }
        .onChange(of: vm.places) { _, newValue in
            guard !newValue.isEmpty else { return }
            SearchHistoryLogger.log(query: vm.destinationQuery, category: .nearbyPlace, context: modelContext)
        }
    }

    private var searchCard: some View {
        GlassCard {
            LocationSearchField(
                title: "Search a destination",
                systemImage: "mappin.circle.fill",
                text: $vm.destinationQuery,
                suggestions: vm.suggestions,
                trailingAction: { Task { await vm.useCurrentLocation() } },
                trailingSystemImage: "location.fill",
                trailingIsLoading: vm.isUsingCurrentLocation,
                onTextChanged: { vm.updateQuery($0) },
                onSelectSuggestion: { vm.selectSuggestion($0) }
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack { NearbyPlacesView() }
}
