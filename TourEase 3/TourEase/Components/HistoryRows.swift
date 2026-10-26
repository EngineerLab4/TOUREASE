import SwiftUI

struct RecentRouteRow: View {
    let route: RecentRouteRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient.touroCTA).frame(width: 42, height: 42)
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
                    .foregroundStyle(.white).font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("\(route.sourceName) → \(route.destinationName)")
                    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                    .lineLimit(1)
                Text("\(route.distanceText) · \(route.timeText)")
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
            Spacer()
            Text(route.timestamp.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 10.5, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}

struct BudgetHistoryRow: View {
    let budget: BudgetRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient.touroAccentCTA).frame(width: 42, height: 42)
                Image(systemName: "indianrupeesign.circle.fill")
                    .foregroundStyle(.white).font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(budget.tripLabel)
                    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                Text("\(budget.tripDays) day\(budget.tripDays == 1 ? "" : "s") · \(budget.createdDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
            Spacer()
            Text("₹\(Int(budget.totalCost.rounded()))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}

struct FavoriteHotelRow: View {
    let hotel: FavoriteHotel

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(hotel.preferredCategory.accentGradient).frame(width: 42, height: 42)
                Image(systemName: "bed.double.fill").foregroundStyle(.white).font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(hotel.name)
                    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                    .lineLimit(1)
                Text(hotel.address)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .lineLimit(1)
            }
            Spacer()
            Text("₹\(Int(hotel.averagePricePerNight.rounded()))")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}

private extension FavoriteHotel {
    var preferredCategory: HotelCategory { HotelCategory(rawValue: categoryRaw) ?? .standard }
}

struct SearchHistoryRow: View {
    let entry: SearchHistoryRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.category.systemImage)
                .foregroundStyle(Color.touroTealLight)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.queryText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                    .lineLimit(1)
                Text(entry.category.displayName)
                    .font(.system(size: 10.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
            Spacer()
            Text(entry.timestamp.formatted(.relative(presentation: .named)))
                .font(.system(size: 10.5, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
