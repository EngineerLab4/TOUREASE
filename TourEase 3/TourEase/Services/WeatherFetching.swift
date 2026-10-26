import Foundation
import CoreLocation
import WeatherKit

protocol WeatherFetching {
    func fetchWeather(for coordinate: CLLocationCoordinate2D, locationName: String) async throws -> WeatherSnapshot
}

/// Real weather via Apple's own WeatherKit framework — this is the "use
/// real APIs wherever Apple allows" path for this module; no third-party
/// weather API or mocking needed for the data itself.
///
/// REQUIRES (one-time Xcode setup, not code):
///  1. A paid Apple Developer Program account (WeatherKit is not available
///     on the free tier).
///  2. Project → Target → Signing & Capabilities → "+ Capability" →
///     WeatherKit.
/// Without both, calls below throw, and `WeatherViewModel` automatically
/// falls back to `SampleWeatherService` with a visible "sample data" notice
/// — it never silently shows mock numbers as if they were live.
final class AppleWeatherService: WeatherFetching {
    private let service = WeatherService.shared

    func fetchWeather(for coordinate: CLLocationCoordinate2D, locationName: String) async throws -> WeatherSnapshot {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await service.weather(for: location)
        let current = weather.currentWeather
        let today = weather.dailyForecast.forecast.first

        return WeatherSnapshot(
            locationName: locationName,
            temperatureC: current.temperature.converted(to: .celsius).value,
            feelsLikeC: current.apparentTemperature.converted(to: .celsius).value,
            humidityPercent: current.humidity * 100,
            precipitationChancePercent: (today?.precipitationChance ?? 0) * 100,
            windSpeedKmh: current.wind.speed.converted(to: .kilometersPerHour).value,
            conditionDescription: current.condition.description,
            symbolName: current.symbolName,
            sunrise: today?.sun.sunrise,
            sunset: today?.sun.sunset,
            isLiveData: true
        )
    }
}

/// Clearly-labeled fallback for environments without the WeatherKit
/// capability configured yet (common for a student project before the
/// paid developer account is set up) — plausible static numbers, never
/// presented as live (`isLiveData: false` drives a visible UI banner).
final class SampleWeatherService: WeatherFetching {
    func fetchWeather(for coordinate: CLLocationCoordinate2D, locationName: String) async throws -> WeatherSnapshot {
        let calendar = Calendar.current
        let now = Date.now
        return WeatherSnapshot(
            locationName: locationName,
            temperatureC: 28,
            feelsLikeC: 30,
            humidityPercent: 58,
            precipitationChancePercent: 20,
            windSpeedKmh: 14,
            conditionDescription: "Partly Cloudy",
            symbolName: "cloud.sun.fill",
            sunrise: calendar.date(bySettingHour: 6, minute: 12, second: 0, of: now),
            sunset: calendar.date(bySettingHour: 18, minute: 45, second: 0, of: now),
            isLiveData: false
        )
    }
}
