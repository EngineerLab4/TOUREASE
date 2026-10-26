import Foundation
import CoreLocation
import Observation

/// Thin, testable wrapper around `CLLocationManager`. Owns permission state
/// and the user's current location so any screen can read it via the
/// environment without touching Core Location directly.
///
/// IMPORTANT (one-time Xcode setup, not code): add these keys to Info.plist
/// (Project → Target → Info tab → "+"):
///   NSLocationWhenInUseUsageDescription
///     "TourEase uses your location to plan routes and find nearby places."
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var authorizationStatus: CLAuthorizationStatus
    var currentLocation: CLLocation?
    var lastError: String?

    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Fetches a single fresh location fix. Requests permission first if needed.
    @MainActor
    func requestCurrentLocation() async throws -> CLLocation {
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error.localizedDescription
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
