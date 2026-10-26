import Foundation
import MapKit
import Observation

@Observable
final class TransportComparisonViewModel: NSObject {
    var sourceName: String = ""
    var destinationName: String = ""
    var activeField: SearchField?
    var suggestions: [PlaceSuggestion] = []

    var isComparing = false
    var errorMessage: String?
    var options: [TransportOption] = []
    var sortMode: ComparisonSort = .balanced

    enum SearchField { case source, destination }

    private let routeService: RouteServicing
    private let comparisonService: TransportComparisonServicing
    private let completer = MKLocalSearchCompleter()
    private var resolvedSource: MKMapItem?
    private var resolvedDestination: MKMapItem?

    init(routeService: RouteServicing = MapKitRouteService(),
         comparisonService: TransportComparisonServicing = TransportComparisonService()) {
        self.routeService = routeService
        self.comparisonService = comparisonService
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    var canCompare: Bool {
        !sourceName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destinationName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Sorted for display — a global "best pick" badge is computed separately
    /// via `recommendedMode` so it doesn't jump around as the user re-sorts.
    var sortedOptions: [TransportOption] {
        let available = options.filter { $0.availability != .unavailable }
        let unavailable = options.filter { $0.availability == .unavailable }
        let sorted: [TransportOption]
        switch sortMode {
        case .cheapest:
            sorted = available.sorted { $0.estimatedCost < $1.estimatedCost }
        case .fastest:
            sorted = available.sorted { $0.estimatedTime < $1.estimatedTime }
        case .balanced:
            sorted = available.sorted { balancedScore($0) < balancedScore($1) }
        }
        return sorted + unavailable
    }

    /// Single "Recommended" badge — lowest normalized cost+time among available options.
    var recommendedMode: TransportMode? {
        options.filter { $0.availability != .unavailable }
            .min { balancedScore($0) < balancedScore($1) }?
            .mode
    }

    private func balancedScore(_ option: TransportOption) -> Double {
        let available = options.filter { $0.availability != .unavailable }
        guard let maxCost = available.map(\.estimatedCost).max(), maxCost > 0,
              let maxTime = available.map(\.estimatedTime).max(), maxTime > 0 else { return 0 }
        let costNorm = option.estimatedCost / maxCost
        let timeNorm = option.estimatedTime / maxTime
        return (costNorm * 0.5) + (timeNorm * 0.5)
    }

    // MARK: - Autocomplete (same pattern as RoutePlannerViewModel)

    func updateQuery(_ text: String, field: SearchField) {
        activeField = field
        switch field {
        case .source: sourceName = text; resolvedSource = nil
        case .destination: destinationName = text; resolvedDestination = nil
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
                switch activeField {
                case .source: resolvedSource = item; sourceName = item.name ?? "Source"
                case .destination: resolvedDestination = item; destinationName = item.name ?? "Destination"
                case .none: break
                }
            } catch {
                errorMessage = "Couldn't resolve that place. Try another search."
            }
        }
        suggestions = []
    }

    // MARK: - Compare

    @MainActor
    func compareTransport() async {
        guard canCompare else { return }
        isComparing = true
        errorMessage = nil
        options = []
        do {
            let source = try await resolveIfNeeded(resolvedSource, query: sourceName)
            let destination = try await resolveIfNeeded(resolvedDestination, query: destinationName)
            options = await comparisonService.compareOptions(from: source, to: destination)
        } catch {
            errorMessage = error.localizedDescription
        }
        isComparing = false
    }

    private func resolveIfNeeded(_ existing: MKMapItem?, query: String) async throws -> MKMapItem {
        if let existing { return existing }
        return try await routeService.resolvePlace(named: query)
    }
}

extension TransportComparisonViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.map(PlaceSuggestion.init)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
