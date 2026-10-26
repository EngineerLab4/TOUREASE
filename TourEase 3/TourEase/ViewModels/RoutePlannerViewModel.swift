import Foundation
import MapKit
import Observation

@Observable
final class RoutePlannerViewModel: NSObject {
    // Form fields
    var tripInput = TripPlanInput()
    var activeSearchField: SearchField?
    var suggestions: [PlaceSuggestion] = []

    // Result state
    var isLoadingRoute = false
    var isUsingCurrentLocation = false
    var errorMessage: String?
    var routeResult: RouteResult?

    enum SearchField { case source, destination }

    private let routeService: RouteServicing
    private let locationManager: LocationManager
    private let completer = MKLocalSearchCompleter()
    private var resolvedSource: MKMapItem?
    private var resolvedDestination: MKMapItem?

    init(routeService: RouteServicing = MapKitRouteService(), locationManager: LocationManager) {
        self.routeService = routeService
        self.locationManager = locationManager
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    var canPlanRoute: Bool {
        !tripInput.sourceName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !tripInput.destinationName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Autocomplete

    func updateQuery(_ text: String, field: SearchField) {
        activeSearchField = field
        switch field {
        case .source: tripInput.sourceName = text; resolvedSource = nil
        case .destination: tripInput.destinationName = text; resolvedDestination = nil
        }
        guard text.count >= 2 else { suggestions = []; return }
        completer.queryFragment = text
    }

    @MainActor
    func selectSuggestion(_ suggestion: PlaceSuggestion) {
        let request = MKLocalSearch.Request(completion: suggestion.underlyingCompletion)
        Task {
            do {
                let response = try await MKLocalSearch(request: request).start()
                guard let item = response.mapItems.first else { return }
                apply(item: item, to: activeSearchField)
            } catch {
                errorMessage = "Couldn't resolve that place. Try another search."
            }
        }
        suggestions = []
    }

    private func apply(item: MKMapItem, to field: SearchField?) {
        let name = item.name ?? "Selected location"
        switch field {
        case .source:
            resolvedSource = item
            tripInput.sourceName = name
        case .destination:
            resolvedDestination = item
            tripInput.destinationName = name
        case .none: break
        }
    }

    // MARK: - Current location

    @MainActor
    func useCurrentLocationAsSource() async {
        isUsingCurrentLocation = true
        errorMessage = nil
        defer { isUsingCurrentLocation = false }
        do {
            let location = try await locationManager.requestCurrentLocation()
            let item = MKMapItem(location: location, address: nil)
            item.name = "Current Location"
            resolvedSource = item
            tripInput.sourceName = "Current Location"
        } catch {
            errorMessage = "Couldn't get your current location. Check Location permissions in Settings."
        }
    }

    // MARK: - Route calculation

    @MainActor
    func planRoute() async {
        guard canPlanRoute else { return }
        isLoadingRoute = true
        errorMessage = nil
        routeResult = nil
        do {
            let source = try await resolveIfNeeded(resolvedSource, query: tripInput.sourceName)
            let destination = try await resolveIfNeeded(resolvedDestination, query: tripInput.destinationName)
            let result = try await routeService.calculateRoute(from: source, to: destination, transportType: .automobile)
            routeResult = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingRoute = false
    }

    private func resolveIfNeeded(_ existing: MKMapItem?, query: String) async throws -> MKMapItem {
        if let existing { return existing }
        return try await routeService.resolvePlace(named: query)
    }
}

extension RoutePlannerViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.map(PlaceSuggestion.init)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
