import Foundation
import MapKit
import CoreLocation
import Observation

@Observable
final class NearbyPlacesViewModel: NSObject {
    var destinationQuery: String = ""
    var suggestions: [PlaceSuggestion] = []
    var selectedCategory: NearbyCategory = .touristAttractions

    var isSearching = false
    var isUsingCurrentLocation = false
    var errorMessage: String?
    var places: [NearbyPlace] = []

    /// The coordinate the last successful search was centered on — kept so
    /// tapping a different category chip can silently re-search without
    /// the user re-entering a destination.
    private var resolvedCenter: CLLocationCoordinate2D?

    private let searchService: NearbyPlacesSearching
    private let locationManager: LocationManager
    private let completer = MKLocalSearchCompleter()

    init(searchService: NearbyPlacesSearching = NearbyPlacesSearchService(),
         locationManager: LocationManager) {
        self.searchService = searchService
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
                await search(center: item.compatCoordinate)
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
            await search(center: location.coordinate)
        } catch {
            errorMessage = "Couldn't get your current location. Check Location permissions in Settings."
        }
    }

    /// Called when the user taps a category chip. Re-searches immediately
    /// if a center is already known; otherwise just switches the selection.
    func selectCategory(_ category: NearbyCategory) {
        selectedCategory = category
        guard let center = resolvedCenter else { return }
        Task { await search(center: center) }
    }

    @MainActor
    func search(center: CLLocationCoordinate2D) async {
        resolvedCenter = center
        isSearching = true
        errorMessage = nil
        do {
            places = try await searchService.search(category: selectedCategory, center: center)
        } catch {
            places = []
            errorMessage = error.localizedDescription
        }
        isSearching = false
    }
}

extension NearbyPlacesViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.map(PlaceSuggestion.init)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
