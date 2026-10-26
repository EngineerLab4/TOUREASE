import Foundation
import MapKit
import CoreLocation

/// Thin helpers over `MKMapItem` using the iOS 26 `location` / `address`
/// APIs (the project's deployment target is iOS 26.5, so the deprecated
/// `placemark` API is no longer needed).
extension MKMapItem {
    /// A best-effort address string for display.
    var compatFormattedAddress: String {
        if let address, !address.fullAddress.isEmpty {
            return address.fullAddress
        }
        return "Nearby"
    }

    /// The item's coordinate.
    var compatCoordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}
