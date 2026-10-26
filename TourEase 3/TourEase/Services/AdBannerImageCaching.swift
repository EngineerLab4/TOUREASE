import Foundation

protocol AdBannerImageCaching {
    /// Takes plain `Sendable` values rather than the `AdBanner` SwiftData
    /// model itself — `@Model` types aren't `Sendable`, so passing one
    /// directly across this `async` boundary triggers a Swift 6 strict
    /// concurrency warning. The caller extracts what it needs before
    /// calling in.
    func loadImageData(id: String, imageURLString: String) async -> Data?
}

/// Downloads and caches ad banner images to disk so they still render after
/// being seen once even without a network connection — the "offline
/// fallback cache" requirement. A real network fetch is tried first; only
/// on failure (offline, bad URL, timeout, non-200 response) does it fall
/// back to whatever was cached from a previous successful load. If neither
/// succeeds, callers get `nil` and the UI shows a text-only banner rather
/// than a broken image — never a fabricated placeholder image.
final class AdBannerImageCache: AdBannerImageCaching {
    static let shared = AdBannerImageCache()
    private let directory: URL

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        directory = caches.appendingPathComponent("AdBannerCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func loadImageData(id: String, imageURLString: String) async -> Data? {
        let cacheFile = directory.appendingPathComponent(id)

        if let url = URL(string: imageURLString),
           imageURLString.lowercased().hasPrefix("http") {
            if let (data, response) = try? await URLSession.shared.data(from: url),
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               !data.isEmpty {
                try? data.write(to: cacheFile)
                return data
            }
        }

        // Offline, empty URL, or the fetch above failed — fall back to the
        // last successfully cached copy of this banner, if one exists.
        return try? Data(contentsOf: cacheFile)
    }
}
