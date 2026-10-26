import SwiftUI
import SwiftData

struct WeatherView: View {
    @State private var locationManager = LocationManager()
    @State private var vm: WeatherViewModel
    @Environment(\.modelContext) private var modelContext

    private let gridColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    init() {
        let manager = LocationManager()
        _locationManager = State(initialValue: manager)
        _vm = State(initialValue: WeatherViewModel(locationManager: manager))
    }

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

                    if vm.isLoading {
                        weatherSkeleton
                    } else if let snapshot = vm.snapshot {
                        if !snapshot.isLiveData {
                            sampleDataBanner
                        }
                        heroCard(snapshot)
                        statsGrid(snapshot)
                        adviceCard(snapshot)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Weather")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { locationManager.requestPermission() }
        .onChange(of: vm.snapshot?.locationName) { _, newValue in
            guard let name = newValue else { return }
            SearchHistoryLogger.log(query: name, category: .weather, context: modelContext)
        }
    }

    private var weatherSkeleton: some View {
        VStack(spacing: 18) {
            GlassCard {
                VStack(spacing: 10) {
                    SkeletonBlock().frame(width: 90, height: 12)
                    SkeletonBlock(cornerRadius: 22).frame(width: 44, height: 44)
                    SkeletonBlock().frame(width: 100, height: 34)
                    SkeletonBlock().frame(width: 120, height: 14)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    SkeletonBlock(cornerRadius: 16).frame(height: 84)
                }
            }
            .padding(.horizontal, 20)
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

    private var sampleDataBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill").foregroundStyle(Color.touroSunset)
            Text("Showing sample data — enable the WeatherKit capability (see README) for live weather.")
                .font(.system(size: 11.5, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func heroCard(_ snapshot: WeatherSnapshot) -> some View {
        GlassCard {
            VStack(spacing: 6) {
                Text(snapshot.locationName)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)

                Image(systemName: snapshot.symbolName)
                    .font(.system(size: 44))
                    .foregroundStyle(LinearGradient.touroCTA)
                    .symbolRenderingMode(.multicolor)
                    .padding(.vertical, 4)

                Text(snapshot.temperatureText)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(snapshot.conditionDescription)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)

                Text(snapshot.feelsLikeText)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }

    private func statsGrid(_ snapshot: WeatherSnapshot) -> some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            WeatherStatTile(icon: "humidity.fill", label: "Humidity", value: snapshot.humidityText)
            WeatherStatTile(icon: "cloud.rain.fill", label: "Rain Chance", value: snapshot.rainText)
            WeatherStatTile(icon: "wind", label: "Wind", value: snapshot.windText)
            WeatherStatTile(icon: "sunrise.fill", label: "Sunrise", value: snapshot.sunriseText)
            WeatherStatTile(icon: "sunset.fill", label: "Sunset", value: snapshot.sunsetText)
            WeatherStatTile(icon: "thermometer.medium", label: "Feels Like", value: "\(Int(snapshot.feelsLikeC.rounded()))°C")
        }
        .padding(.horizontal, 20)
    }

    private func adviceCard(_ snapshot: WeatherSnapshot) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.touroSunset)
                Text(snapshot.advice)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack { WeatherView() }
}
