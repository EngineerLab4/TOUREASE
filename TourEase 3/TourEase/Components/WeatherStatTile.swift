import SwiftUI

struct WeatherStatTile: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.touroTealLight)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10.5, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCardStyle(cornerRadius: 16)
    }
}
