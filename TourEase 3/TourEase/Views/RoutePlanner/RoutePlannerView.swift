import SwiftUI
import MapKit
import SwiftData

struct RoutePlannerView: View {
    @State private var locationManager = LocationManager()
    @State private var vm: RoutePlannerViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    @Environment(\.modelContext) private var modelContext

    init() {
        let manager = LocationManager()
        _locationManager = State(initialValue: manager)
        _vm = State(initialValue: RoutePlannerViewModel(locationManager: manager))
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 18) {
                    formCard

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.touroSunset)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }

                    if let result = vm.routeResult {
                        mapCard(result)
                        travelSummaryCard(result)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Route Planner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { locationManager.requestPermission() }
    }

    // MARK: - Form

    private var formCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                LocationSearchField(
                    title: "Source",
                    systemImage: "location.circle.fill",
                    text: $vm.tripInput.sourceName,
                    suggestions: vm.activeSearchField == .source ? vm.suggestions : [],
                    trailingAction: { Task { await vm.useCurrentLocationAsSource() } },
                    trailingSystemImage: "location.fill",
                    trailingIsLoading: vm.isUsingCurrentLocation,
                    onTextChanged: { vm.updateQuery($0, field: .source) },
                    onSelectSuggestion: { vm.selectSuggestion($0) }
                )

                LocationSearchField(
                    title: "Destination",
                    systemImage: "mappin.circle.fill",
                    text: $vm.tripInput.destinationName,
                    suggestions: vm.activeSearchField == .destination ? vm.suggestions : [],
                    onTextChanged: { vm.updateQuery($0, field: .destination) },
                    onSelectSuggestion: { vm.selectSuggestion($0) }
                )

                DatePicker("Travel Date", selection: $vm.tripInput.travelDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(.touroTeal)
                    .foregroundStyle(Color.touroTextPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.06))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.touroGlassStroke, lineWidth: 1))

                HStack(spacing: 12) {
                    stepperPill(title: "Days", value: $vm.tripInput.tripDays, range: 1...30, icon: "calendar")
                    stepperPill(title: "People", value: $vm.tripInput.peopleCount, range: 1...20, icon: "person.2.fill")
                }

                PrimaryButton(title: "Find Route", isLoading: vm.isLoadingRoute) {
                    Task {
                        await vm.planRoute()
                        if let result = vm.routeResult {
                            focusCamera(on: result)
                            modelContext.insert(RecentRouteRecord(result: result))
                            try? modelContext.save()
                        }
                    }
                }
                .opacity(vm.canPlanRoute ? 1 : 0.5)
                .disabled(!vm.canPlanRoute || vm.isLoadingRoute)
            }
        }
        .padding(.horizontal, 20)
    }

    private func stepperPill(title: String, value: Binding<Int>, range: ClosedRange<Int>, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(Color.touroTealLight).font(.system(size: 13))
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.system(size: 10.5, design: .rounded)).foregroundStyle(Color.touroTextMuted)
                Text("\(value.wrappedValue)").font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
            Stepper("", value: value, in: range)
                .labelsHidden()
                .tint(.touroTeal)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.touroGlassStroke, lineWidth: 1))
    }

    // MARK: - Map

    private func mapCard(_ result: RouteResult) -> some View {
        Map(position: $cameraPosition) {
            Marker("Source", systemImage: "location.circle.fill", coordinate: result.sourceCoordinate)
                .tint(Color.touroTealLight)
            Marker(result.destinationName, systemImage: "mappin.circle.fill", coordinate: result.destinationCoordinate)
                .tint(Color.touroSunset)
            MapPolyline(result.polyline)
                .stroke(Color.touroTealLight, lineWidth: 5)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.touroGlassStroke, lineWidth: 1))
        .padding(.horizontal, 20)
        .mapStyle(.standard(elevation: .automatic))
    }

    private func focusCamera(on result: RouteResult) {
        let rect = result.polyline.boundingMapRect
        withAnimation {
            cameraPosition = .rect(rect)
        }
    }

    // MARK: - Travel summary

    private func travelSummaryCard(_ result: RouteResult) -> some View {
        GlassCard {
            VStack(spacing: 14) {
                Text("Travel Summary")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    summaryStat(icon: "point.topleft.down.curvedto.point.bottomright.up.fill",
                                label: "Distance", value: result.distanceText)
                    summaryStat(icon: "clock.fill", label: "ETA", value: result.etaText)
                }
                HStack(spacing: 12) {
                    summaryStat(icon: "calendar", label: "Trip Days", value: "\(vm.tripInput.tripDays)")
                    summaryStat(icon: "person.2.fill", label: "People", value: "\(vm.tripInput.peopleCount)")
                }

                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill").foregroundStyle(Color.touroTealLight)
                    Text("\(result.sourceName) → \(result.destinationName)")
                        .font(.system(size: 12.5, design: .rounded))
                        .foregroundStyle(Color.touroTextMuted)
                        .lineLimit(1)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func summaryStat(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(Color.touroTealLight)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10.5, design: .rounded))
                .foregroundStyle(Color.touroTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack { RoutePlannerView() }
}
