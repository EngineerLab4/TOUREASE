import Foundation
import MapKit
import Observation

@Observable
final class HotelsViewModel: NSObject {
    var destinationQuery: String = ""
    var suggestions: [PlaceSuggestion] = []
    var nameFilter: String = ""
    var categoryFilter: HotelCategoryFilter = .all
    var sortOption: HotelSortOption = .nearest

    var isSearching = false
    var errorMessage: String?
    var hotels: [Hotel] = []

    private let searchService: HotelSearching
    private let completer = MKLocalSearchCompleter()

    init(searchService: HotelSearching = HotelSearchService()) {
        self.searchService = searchService
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    var displayedHotels: [Hotel] {
        var result = hotels
        if let category = categoryFilter.hotelCategory {
            result = result.filter { $0.category == category }
        }
        if !nameFilter.trimmingCharacters(in: .whitespaces).isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(nameFilter) }
        }
        switch sortOption {
        case .priceLowToHigh: result.sort { $0.averagePricePerNight < $1.averagePricePerNight }
        case .ratingHighToLow: result.sort { $0.averageRating > $1.averageRating }
        case .nearest: result.sort { $0.distanceMeters < $1.distanceMeters }
        }
        return result
    }

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
            hotels = try await searchService.searchHotels(near: destinationQuery)
        } catch {
            hotels = []
            errorMessage = error.localizedDescription
        }
        isSearching = false
    }
}

extension HotelsViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.map(PlaceSuggestion.init)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
