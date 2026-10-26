import SwiftUI

struct TransportComparisonView: View {
    @State private var vm = TransportComparisonViewModel()
    @Namespace private var sortNamespace

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

                    if !vm.options.isEmpty {
                        sortControl

                        LazyVStack(spacing: 12) {
                            ForEach(vm.sortedOptions) { option in
                                TransportOptionCard(option: option, isRecommended: option.mode == vm.recommendedMode)
                            }
                        }
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.25), value: vm.sortMode)
                    } else if vm.isComparing {
                        SkeletonResultList().padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Compare Transport")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var formCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                LocationSearchField(
                    title: "Source",
                    systemImage: "location.circle.fill",
                    text: $vm.sourceName,
                    suggestions: vm.activeField == .source ? vm.suggestions : [],
                    onTextChanged: { vm.updateQuery($0, field: .source) },
                    onSelectSuggestion: { vm.selectSuggestion($0) }
                )

                LocationSearchField(
                    title: "Destination",
                    systemImage: "mappin.circle.fill",
                    text: $vm.destinationName,
                    suggestions: vm.activeField == .destination ? vm.suggestions : [],
                    onTextChanged: { vm.updateQuery($0, field: .destination) },
                    onSelectSuggestion: { vm.selectSuggestion($0) }
                )

                PrimaryButton(title: "Compare", isLoading: vm.isComparing) {
                    Task { await vm.compareTransport() }
                }
                .opacity(vm.canCompare ? 1 : 0.5)
                .disabled(!vm.canCompare || vm.isComparing)
            }
        }
        .padding(.horizontal, 20)
    }

    private var sortControl: some View {
        HStack(spacing: 8) {
            ForEach(ComparisonSort.allCases) { option in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) { vm.sortMode = option }
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(vm.sortMode == option ? .white : Color.touroTextMuted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            if vm.sortMode == option {
                                Capsule()
                                    .fill(LinearGradient.touroCTA)
                                    .matchedGeometryEffect(id: "sort", in: sortNamespace)
                            } else {
                                Capsule().fill(Color.white.opacity(0.06))
                            }
                        }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack { TransportComparisonView() }
}
