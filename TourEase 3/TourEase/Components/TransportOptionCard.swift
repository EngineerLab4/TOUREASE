import SwiftUI

/// One row in the comparison list. Built on the existing `glassCardStyle`
/// language; new component since none of the Phase 1/Module 1-2 cards match
/// this "stat row + chips" shape.
struct TransportOptionCard: View {
    let option: TransportOption
    let isRecommended: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(option.mode.tint.opacity(0.22)).frame(width: 46, height: 46)
                    Image(systemName: option.mode.systemImage)
                        .foregroundStyle(option.mode.tint)
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(option.mode.title)
                            .font(.system(size: 15.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.touroTextPrimary)
                        if isRecommended {
                            Text("RECOMMENDED")
                                .font(.system(size: 8.5, weight: .bold, design: .rounded))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(LinearGradient.touroCTA)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(option.dataSourceLabel)
                        .font(.system(size: 10.5, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                }

                Spacer()

                Text(option.costText)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.touroTealLight)
            }

            HStack(spacing: 10) {
                statChip(icon: "point.topleft.down.curvedto.point.bottomright.up.fill", value: option.distanceText)
                statChip(icon: "clock.fill", value: option.etaText)
                chip(text: option.trafficCondition.rawValue, color: option.trafficCondition.color, icon: "car.top.radiowaves.front.fill")
                chip(text: option.availability.rawValue, color: option.availability.color, icon: "checkmark.circle.fill")
            }
        }
        .padding(16)
        .glassCardStyle(cornerRadius: 20)
        .opacity(option.availability == .unavailable ? 0.55 : 1)
    }

    private func statChip(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10))
            Text(value).font(.system(size: 11.5, weight: .medium, design: .rounded))
        }
        .foregroundStyle(Color.touroTextPrimary)
        .padding(.horizontal, 9).padding(.vertical, 6)
        .background(.white.opacity(0.07))
        .clipShape(Capsule())
    }

    private func chip(text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(.system(size: 11, weight: .medium, design: .rounded))
        }
        .foregroundStyle(Color.touroTextMuted)
        .padding(.horizontal, 9).padding(.vertical, 6)
        .background(.white.opacity(0.05))
        .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        VStack(spacing: 12) {
            TransportOptionCard(option: TransportOption(
                mode: .car, distanceMeters: 24_000, estimatedTime: 2100, estimatedCost: 210,
                trafficCondition: .moderate, availability: .available, isDistanceLive: true, isTimeLive: true
            ), isRecommended: true)
            TransportOptionCard(option: TransportOption(
                mode: .flight, distanceMeters: 900_000, estimatedTime: 8400, estimatedCost: 7350,
                trafficCondition: .notApplicable, availability: .unavailable, isDistanceLive: true, isTimeLive: false
            ), isRecommended: false)
        }
        .padding(20)
    }
}
