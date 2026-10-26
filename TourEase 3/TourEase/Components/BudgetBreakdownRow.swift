import SwiftUI

/// One line of the cost breakdown — icon dot + label + amount. Small enough
/// it wasn't worth generalizing beyond the Budget Planner's `BudgetSlice`.
struct BudgetBreakdownRow: View {
    let slice: BudgetSlice
    let total: Double

    private var percent: Int {
        guard total > 0 else { return 0 }
        return Int((slice.amount / total) * 100)
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(slice.color).frame(width: 10, height: 10)
            Text(slice.label)
                .font(.system(size: 13.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color.touroTextPrimary)
            Spacer()
            Text("\(percent)%")
                .font(.system(size: 11.5, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
            Text("₹\(Int(slice.amount.rounded()))")
                .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 76, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
