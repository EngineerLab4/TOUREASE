import SwiftUI
import Charts
import SwiftData

struct BudgetPlannerView: View {
    @State private var vm = BudgetPlannerViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 18) {
                    formCard
                    chartCard
                    breakdownCard
                    saveCard
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Budget Planner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Form

    private var formCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                stepperRow(title: "Trip Days", value: $vm.input.tripDays, range: 1...30, icon: "calendar")

                PillSegmentedControl(title: "Hotel Category", selection: $vm.input.hotelCategory)
                PillSegmentedControl(title: "Food Preference", selection: $vm.input.foodPreference)

                Text("Local Transport Usage")
                    .font(.system(size: 12.5, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)

                PillSegmentedControl(title: "Taxi", selection: $vm.input.taxiUsage)
                PillSegmentedControl(title: "Auto", selection: $vm.input.autoUsage)
                PillSegmentedControl(title: "Metro", selection: $vm.input.metroUsage)

                sliderRow(title: "Shopping Budget", value: $vm.input.shoppingBudget, range: 0...20000, step: 500)
                sliderRow(title: "Activities Budget", value: $vm.input.activitiesBudget, range: 0...15000, step: 500)
                sliderRow(title: "Emergency Buffer", value: $vm.input.emergencyBufferPercent, range: 0...30, step: 1, isPercent: true)
            }
        }
        .padding(.horizontal, 20)
        .onChange(of: vm.input) { _, _ in vm.recalculate() }
    }

    private func stepperRow(title: String, value: Binding<Int>, range: ClosedRange<Int>, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(Color.touroTealLight).font(.system(size: 13))
            Text(title).font(.system(size: 13.5, design: .rounded)).foregroundStyle(Color.touroTextPrimary)
            Spacer()
            Text("\(value.wrappedValue)").font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white)
            Stepper("", value: value, in: range).labelsHidden().tint(.touroTeal)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, isPercent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12.5, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                Spacer()
                Text(isPercent ? "\(Int(value.wrappedValue))%" : "₹\(Int(value.wrappedValue))")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Slider(value: value, in: range, step: step).tint(.touroTeal)
        }
    }

    // MARK: - Chart

    private var chartCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text("Budget Breakdown")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    Chart(vm.breakdown.slices) { slice in
                        SectorMark(
                            angle: .value("Amount", slice.amount),
                            innerRadius: .ratio(0.62),
                            angularInset: 1.5
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)

                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                        Text("₹\(Int(vm.breakdown.totalCost.rounded()))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Breakdown list

    private var breakdownCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                ForEach(vm.breakdown.slices) { slice in
                    BudgetBreakdownRow(slice: slice, total: vm.breakdown.totalCost)
                }
            }
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.25), value: vm.breakdown.totalCost)
    }

    // MARK: - Save

    private var saveCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                FloatingTextField(title: "Name this trip (optional)", systemImage: "tag.fill", text: $vm.tripLabel)

                if let error = vm.saveError {
                    Text(error)
                        .font(.system(size: 12.5, design: .rounded))
                        .foregroundStyle(Color.touroSunset)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if vm.didSave {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.touroTealLight)
                        Text("Budget saved")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.touroTealLight)
                    }
                    .transition(.opacity)
                }

                PrimaryButton(title: "Save Budget") {
                    vm.saveBudget(context: modelContext)
                }
            }
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut, value: vm.didSave)
    }
}

#Preview {
    NavigationStack { BudgetPlannerView() }
}
