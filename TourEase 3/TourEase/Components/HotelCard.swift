import SwiftUI

struct HotelCard: View {
    let hotel: Hotel
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(hotel.category.accentGradient)
                    .frame(width: 56, height: 56)
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(hotel.name)
                        .font(.system(size: 14.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.touroTextPrimary)
                        .lineLimit(1)
                    Spacer()
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? Color.touroSunset : Color.touroTextMuted)
                    }
                    .accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
                }

                Text(hotel.address)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label(hotel.category.displayName, systemImage: "tag.fill")
                    Label(hotel.ratingText, systemImage: "star.fill")
                    Label(hotel.distanceText, systemImage: "location.fill")
                }
                .font(.system(size: 10.5, design: .rounded))
                .foregroundStyle(Color.touroTealLight)
                .labelStyle(.titleAndIcon)

                HStack {
                    Text(hotel.priceText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Estimated")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.08))
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 18)
    }
}

/// Small helper so `HotelCard` can reuse the same tinted-icon-bubble look
/// as `DashboardDestination` without depending on that enum.
extension HotelCategory {
    var accentGradient: LinearGradient {
        switch self {
        case .budget: return LinearGradient(colors: [.touroTeal, .touroTealLight], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .standard: return LinearGradient(colors: [Color(red: 0.35, green: 0.45, blue: 0.95), Color(red: 0.55, green: 0.65, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .premium: return LinearGradient(colors: [.touroSunset, Color(red: 0.98, green: 0.72, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .luxury: return LinearGradient(colors: [Color(red: 0.85, green: 0.35, blue: 0.55), Color(red: 0.98, green: 0.55, blue: 0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
