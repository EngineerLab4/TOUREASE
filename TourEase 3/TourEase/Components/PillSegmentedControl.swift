import SwiftUI

/// Generic capsule picker for any `LabeledOption` enum. Extracted here
/// because the Budget Planner form needs five of these (hotel category,
/// food preference, three usage levels) — beats duplicating the same
/// selectable-pill-row markup five times, and is reusable by later modules
/// (Hotels/Food filters, etc.) for free.
struct PillSegmentedControl<T: LabeledOption>: View where T.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selection: T
    @Namespace private var selectionNamespace

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)

            HStack(spacing: 8) {
                ForEach(Array(T.allCases)) { option in
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) { selection = option }
                    } label: {
                        Text(option.displayName)
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(selection == option ? .white : Color.touroTextMuted)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background {
                                if selection == option {
                                    // Matched geometry so the highlight glides
                                    // between pills instead of popping.
                                    Capsule()
                                        .fill(LinearGradient.touroCTA)
                                        .matchedGeometryEffect(id: "pill", in: selectionNamespace)
                                } else {
                                    Capsule().fill(Color.white.opacity(0.06))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
