import SwiftUI

/// One tile in the Admin dashboard grid — mirrors `DashboardCard`'s look
/// but stays a separate, simpler component since admin tiles don't need
/// the tourist dashboard's staggered-entrance animation or gradient
/// cycling (a flat, consistent accent reads more "control panel").
struct AdminCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle().fill(LinearGradient.touroAccentCTA).frame(width: 42, height: 42)
                Image(systemName: systemImage).foregroundStyle(.white).font(.system(size: 17, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(height: 118, alignment: .top)
        .frame(maxWidth: .infinity)
        .glassCardStyle(cornerRadius: 20)
        .accessibilityElement(children: .combine)
    }
}

/// One editable rate in a pricing-management screen: label + live-editing
/// currency field. Shared by Manage Hotel/Food/Transport Pricing so the
/// same row markup isn't rewritten three times.
struct PricingRateRow: View {
    let label: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13.5, design: .rounded))
                .foregroundStyle(Color.touroTextPrimary)
            Spacer()
            HStack(spacing: 4) {
                Text("₹")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                TextField("0", value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 70)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// One row in Manage Users — status pill + suspend/delete actions.
struct AdminUserRow: View {
    let user: AppUserRecord
    let onToggleSuspend: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(user.role == .admin ? LinearGradient.touroAccentCTA : LinearGradient.touroCTA)
                    .frame(width: 40, height: 40)
                Text(String(user.name.prefix(1)))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.touroTextPrimary)
                    if user.role == .admin {
                        Text("ADMIN")
                            .font(.system(size: 8.5, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.touroSunset)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Color.touroSunset.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    if user.isSuspended {
                        Text("SUSPENDED")
                            .font(.system(size: 8.5, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Color.red.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(user.email)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }

            Spacer()

            Menu {
                Button(user.isSuspended ? "Unsuspend" : "Suspend", systemImage: "pause.circle", action: onToggleSuspend)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .foregroundStyle(Color.touroTextMuted)
                    .font(.system(size: 18))
            }
            .accessibilityLabel("User actions for \(user.name)")
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}
