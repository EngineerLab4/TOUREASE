import SwiftUI

struct ManageFoodPricingView: View {
    private let defaults = DefaultFoodPricingProvider()
    private let store = PricingOverridesStore.shared

    @State private var rates: [FoodCategory: Double] = [:]
    @State private var didSave = false

    var body: some View {
        ZStack {
            AnimatedBackground()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Edits here update the Food module's Cost Averages grid and Daily/Weekly Average instantly.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .padding(.horizontal, 24)

                    GlassCard {
                        VStack(spacing: 10) {
                            ForEach(FoodCategory.allCases) { category in
                                PricingRateRow(label: category.displayName, value: bindingFor(category))
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
        .navigationTitle("Food Pricing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { loadCurrentRates() }
    }

    private func bindingFor(_ category: FoodCategory) -> Binding<Double> {
        Binding(get: { rates[category] ?? defaults.averageCost(category) },
                set: { rates[category] = $0 })
    }

    private func loadCurrentRates() {
        for category in FoodCategory.allCases {
            rates[category] = store.value(for: "food.\(category.rawValue)") ?? defaults.averageCost(category)
        }
    }

    private func save() {
        for (category, value) in rates {
            store.setValue(value, for: "food.\(category.rawValue)")
        }
        withAnimation { didSave = true }
    }

    private func resetToDefault() {
        for category in FoodCategory.allCases {
            store.setValue(defaults.averageCost(category), for: "food.\(category.rawValue)")
            rates[category] = defaults.averageCost(category)
        }
        withAnimation { didSave = true }
    }
}

#Preview {
    NavigationStack { ManageFoodPricingView() }
}
