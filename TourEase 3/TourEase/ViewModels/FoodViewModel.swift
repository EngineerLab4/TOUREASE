import Foundation
import MapKit
import Observation

@Observable
final class FoodViewModel: NSObject {
    // Always-available cost summary — no search needed for these.
    private let pricing: FoodPricingProviding

    // Nearby place search
    var destinationQuery: String = ""
    var suggestions: [PlaceSuggestion] = []
    var isSearching = false
    var errorMessage: String?
    var places: [FoodPlace] = []

    private let searchService: FoodPlaceSearching
    private let completer = MKLocalSearchCompleter()

    init(pricing: FoodPricingProviding = PersistedFoodPricingProvider(),
         searchService: FoodPlaceSearching = FoodPlaceSearchService()) {
        self.pricing = pricing
        self.searchService = searchService
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    func averageCost(_ category: FoodCategory) -> Double { pricing.averageCost(category) }

    var dailyAverage: Double {
        FoodCategory.allCases
            .filter { $0.countsTowardDailyAverage }
            .reduce(0) { $0 + pricing.averageCost($1) }
    }

    var weeklyAverage: Double { dailyAverage * 7 }

    func updateQuery(_ text: String) {
        destinationQuery = text
        guard text.count >= 2 else { suggestions = []; return }
        completer.queryFragment = text
    }

    func selectSuggestion(_ suggestion: PlaceSuggestion) {
        destinationQuery = suggestion.title
        suggestions = []
        Task { await search() }
    }

    @MainActor
    func search() async {
        guard !destinationQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        errorMessage = nil
        suggestions = []
        do {
            places = try await searchService.searchPlaces(near: destinationQuery)
        } catch {
            places = []
            errorMessage = error.localizedDescription
        }
        isSearching = false
    }
}

extension FoodViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.map(PlaceSuggestion.init)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
