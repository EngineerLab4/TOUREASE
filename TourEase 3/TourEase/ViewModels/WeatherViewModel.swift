import Foundation
import MapKit
import CoreLocation
import Observation

@Observable
final class WeatherViewModel: NSObject {
    var destinationQuery: String = ""
    var suggestions: [PlaceSuggestion] = []

    var isLoading = false
    var isUsingCurrentLocation = false
    var errorMessage: String?
    var snapshot: WeatherSnapshot?

    private let liveService: WeatherFetching
    private let sampleService: WeatherFetching
    private let locationManager: LocationManager
    private let completer = MKLocalSearchCompleter()

    init(liveService: WeatherFetching = AppleWeatherService(),
         sampleService: WeatherFetching = SampleWeatherService(),
         locationManager: LocationManager) {
        self.liveService = liveService
        self.sampleService = sampleService
        self.locationManager = locationManager
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    func updateQuery(_ text: String) {
        destinationQuery = text
        guard text.count >= 2 else { suggestions = []; return }
        completer.queryFragment = text
    }

    func selectSuggestion(_ suggestion: PlaceSuggestion) {
        destinationQuery = suggestion.title
        suggestions = []
        Task {
            let request = MKLocalSearch.Request(completion: suggestion.underlyingCompletion)
            if let response = try? await MKLocalSearch(request: request).start(),
               let item = response.mapItems.first {
                await fetchWeather(coordinate: item.compatCoordinate, name: suggestion.title)
            }
        }
    }

    @MainActor
    func useCurrentLocation() async {
        isUsingCurrentLocation = true
        errorMessage = nil
        defer { isUsingCurrentLocation = false }
        do {
            let location = try await locationManager.requestCurrentLocation()
            destinationQuery = "Current Location"
            await fetchWeather(coordinate: location.coordinate, name: "Current Location")
        } catch {
            errorMessage = "Couldn't get your current location. Check Location permissions in Settings."
        }
    }

    @MainActor
    func fetchWeather(coordinate: CLLocationCoordinate2D, name: String) async {
        isLoading = true
        errorMessage = nil
        do {
            snapshot = try await liveService.fetchWeather(for: coordinate, locationName: name)
        } catch {
            // WeatherKit not configured (missing capability/paid account) or
            // a network failure — fall back to clearly-labeled sample data
            // rather than leaving the screen blank.
            snapshot = try? await sampleService.fetchWeather(for: coordinate, locationName: name)
            if snapshot == nil {
                errorMessage = "Couldn't load weather right now. Try again."
            }
        }
        isLoading = false
    }
}

extension WeatherViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.map(PlaceSuggestion.init)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
