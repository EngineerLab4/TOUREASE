import SwiftUI

/// One cost-category tile in the summary grid.
struct FoodCostCard: View {
    let category: FoodCategory
    let amount: Double

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.systemImage)
                .font(.system(size: 18))
                .foregroundStyle(Color.touroTealLight)
            Text(category.displayName)
                .font(.system(size: 11.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
            Text("₹\(Int(amount.rounded()))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCardStyle(cornerRadius: 16)
    }
}

/// One nearby restaurant/cafe row.
struct FoodPlaceCard: View {
    let place: FoodPlace

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(place.venueType == .restaurant ? LinearGradient.touroAccentCTA : LinearGradient.touroCTA)
                    .frame(width: 46, height: 46)
                Image(systemName: place.venueType == .restaurant ? "fork.knife" : "cup.and.saucer.fill")
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                    .lineLimit(1)
                Text(place.address)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(place.venueType.displayName)
                    Text("·")
                    Text(place.distanceText)
                }
                .font(.system(size: 10.5, design: .rounded))
                .foregroundStyle(Color.touroTealLight)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(place.costText)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Estimated")
                    .font(.system(size: 8.5, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 18)
    }
}
