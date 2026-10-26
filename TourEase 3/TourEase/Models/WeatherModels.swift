import Foundation

struct WeatherSnapshot {
    let locationName: String
    let temperatureC: Double
    let feelsLikeC: Double
    let humidityPercent: Double
    let precipitationChancePercent: Double
    let windSpeedKmh: Double
    let conditionDescription: String
    let symbolName: String
    let sunrise: Date?
    let sunset: Date?
    /// `false` when this came from `SampleWeatherService` rather than real
    /// WeatherKit data — surfaced in the UI so sample data is never mistaken
    /// for live conditions.
    let isLiveData: Bool

    var temperatureText: String { "\(Int(temperatureC.rounded()))°C" }
    var feelsLikeText: String { "Feels like \(Int(feelsLikeC.rounded()))°C" }
    var humidityText: String { "\(Int(humidityPercent.rounded()))%" }
    var rainText: String { "\(Int(precipitationChancePercent.rounded()))%" }
    var windText: String { "\(Int(windSpeedKmh.rounded())) km/h" }

    var sunriseText: String { Self.timeText(sunrise) }
    var sunsetText: String { Self.timeText(sunset) }

    private static func timeText(_ date: Date?) -> String {
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Simple rule-based advice synthesized from the real fetched numbers —
    /// not a live "advice API" (none exists), just a derived recommendation,
    /// which is a different thing from fabricating live data.
    var advice: String {
        if precipitationChancePercent >= 60 {
            return "High chance of rain — carry an umbrella and plan indoor backups."
        }
        if temperatureC >= 35 {
            return "Very hot today — stay hydrated and avoid midday outdoor activity."
        }
        if temperatureC <= 10 {
            return "Cold conditions — dress in layers, especially for early morning plans."
        }
        if windSpeedKmh >= 30 {
            return "Windy conditions — secure loose belongings and be cautious near open areas."
        }
        if humidityPercent >= 80 {
            return "Humid today — light, breathable clothing is recommended."
        }
        return "Pleasant conditions — a good day for sightseeing outdoors."
    }
}
