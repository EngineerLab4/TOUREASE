import SwiftUI

struct NearbyPlaceCard: View {
    let place: NearbyPlace

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(LinearGradient.touroCTA).frame(width: 46, height: 46)
                Image(systemName: place.category.systemImage)
                    .foregroundStyle(.white)
                    .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                    .lineLimit(1)
                Text(place.address)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .lineLimit(1)
            }

            Spacer()

            Text(place.distanceText)
                .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.touroTealLight)
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 18)
    }
}
