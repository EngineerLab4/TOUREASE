import SwiftUI

struct ManageHotelPricingView: View {
    private let defaults = DefaultBudgetPricingProvider()
    private let store = PricingOverridesStore.shared

    @State private var rates: [HotelCategory: Double] = [:]
    @State private var didSave = false

    var body: some View {
        ZStack {
            AnimatedBackground()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Edits here update the Hotels module's estimates and the Budget Planner's hotel cost instantly — both read from the same rate table.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .padding(.horizontal, 24)

                    GlassCard {
                        VStack(spacing: 10) {
                            ForEach(HotelCategory.allCases) { category in
                                PricingRateRow(label: "\(category.displayName) / night", value: bindingFor(category))
                            }
                        }
                    }
                    .padding(.horizontal, 20)

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
        .navigationTitle("Hotel Pricing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { loadCurrentRates() }
    }

    private func bindingFor(_ category: HotelCategory) -> Binding<Double> {
        Binding(get: { rates[category] ?? defaults.hotelRatePerNight(category) },
                set: { rates[category] = $0 })
    }

    private func loadCurrentRates() {
        for category in HotelCategory.allCases {
            rates[category] = store.value(for: "hotel.\(category.rawValue)") ?? defaults.hotelRatePerNight(category)
        }
    }

    private func save() {
        for (category, value) in rates {
            store.setValue(value, for: "hotel.\(category.rawValue)")
        }
        withAnimation { didSave = true }
    }

    private func resetToDefault() {
        for category in HotelCategory.allCases {
            store.setValue(defaults.hotelRatePerNight(category), for: "hotel.\(category.rawValue)")
            rates[category] = defaults.hotelRatePerNight(category)
        }
        withAnimation { didSave = true }
    }
}

#Preview {
    NavigationStack { ManageHotelPricingView() }
}
