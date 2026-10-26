import SwiftUI

struct ManageTransportPricingView: View {
    private let defaults = DefaultTransportPricingProvider()
    private let store = PricingOverridesStore.shared

    @State private var baseFares: [TransportMode: Double] = [:]
    @State private var perKmRates: [TransportMode: Double] = [:]
    @State private var didSave = false

    /// Walking has no fare to edit — omit it from the editable list.
    private var editableModes: [TransportMode] { TransportMode.allCases.filter { $0 != .walking } }

    var body: some View {
        ZStack {
            AnimatedBackground()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Edits here update the Transport Comparison module's estimated cost for each mode instantly.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .padding(.horizontal, 24)

                    ForEach(editableModes) { mode in
                        GlassCard {
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: mode.systemImage).foregroundStyle(Color.touroTealLight)
                                    Text(mode.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                PricingRateRow(label: "Base fare", value: baseFareBinding(mode))
                                PricingRateRow(label: "Per km rate", value: perKmBinding(mode))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if didSave {
                        Text("Saved").font(.system(size: 12.5, design: .rounded)).foregroundStyle(Color.touroTealLight)
                    }

                    HStack(spacing: 12) {
                        PrimaryButton(title: "Save Rates") { save() }
                        PrimaryButton(title: "Reset to Default", gradient: .touroAccentCTA) { resetToDefault() }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Transport Pricing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { loadCurrentRates() }
    }

    private func baseFareBinding(_ mode: TransportMode) -> Binding<Double> {
        Binding(get: { baseFares[mode] ?? defaults.baseFare(for: mode) },
                set: { baseFares[mode] = $0 })
    }

    private func perKmBinding(_ mode: TransportMode) -> Binding<Double> {
        Binding(get: { perKmRates[mode] ?? defaults.perKmRate(for: mode) },
                set: { perKmRates[mode] = $0 })
    }

    private func loadCurrentRates() {
        for mode in editableModes {
            baseFares[mode] = store.value(for: "transport.base.\(mode.rawValue)") ?? defaults.baseFare(for: mode)
            perKmRates[mode] = store.value(for: "transport.perKm.\(mode.rawValue)") ?? defaults.perKmRate(for: mode)
        }
    }

    private func save() {
        for mode in editableModes {
            if let base = baseFares[mode] { store.setValue(base, for: "transport.base.\(mode.rawValue)") }
            if let perKm = perKmRates[mode] { store.setValue(perKm, for: "transport.perKm.\(mode.rawValue)") }
        }
        withAnimation { didSave = true }
    }

    private func resetToDefault() {
        for mode in editableModes {
            store.setValue(defaults.baseFare(for: mode), for: "transport.base.\(mode.rawValue)")
            store.setValue(defaults.perKmRate(for: mode), for: "transport.perKm.\(mode.rawValue)")
            baseFares[mode] = defaults.baseFare(for: mode)
            perKmRates[mode] = defaults.perKmRate(for: mode)
        }
        withAnimation { didSave = true }
    }
}

#Preview {
    NavigationStack { ManageTransportPricingView() }
}
