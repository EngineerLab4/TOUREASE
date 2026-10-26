import SwiftUI

/// The real Home Dashboard — replaces `RootView`'s old `DashboardPlaceholderView`.
/// Reuses `AnimatedBackground`, `glassCardStyle`, and the app's existing color
/// system; introduces no new visual language.
struct DashboardView: View {
    let user: AppUser
    @Environment(SessionManager.self) private var session
    @State private var path: [DashboardDestination] = []

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AnimatedBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        header

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Array(DashboardDestination.allCases.enumerated()), id: \.element) { index, destination in
                                Button {
                                    path.append(destination)
                                } label: {
                                    DashboardCard(destination: destination, appearIndex: index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(for: DashboardDestination.self) { destination in
                switch destination {
                case .emergency:
                    EmergencyView()
                case .routePlanner:
                    RoutePlannerView()
                case .compareTransport:
                    TransportComparisonView()
                case .budgetPlanner:
                    BudgetPlannerView()
                case .hotels:
                    HotelsView()
                case .food:
                    FoodView()
                case .nearbyPlaces:
                    NearbyPlacesView()
                case .weather:
                    WeatherView()
                case .history:
                    HistoryView()
                case .savedTrips:
                    // "Trips" and "Recent Routes" are the same underlying
                    // data (a calculated route already captures source,
                    // destination, distance, time) — both cards open the
                    // same History screen rather than showing a near-empty
                    // duplicate list.
                    HistoryView()
                case .profile:
                    ProfileView(user: user)
                default:
                    ComingSoonView(destination: destination)
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                Text(user.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button {
                path.append(.profile)
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient.touroCTA)
                        .frame(width: 44, height: 44)
                    Text(initials)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var initials: String {
        let parts = user.name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "T" : String(letters).uppercased()
    }
}

#Preview {
    DashboardView(user: AppUser(id: "1", name: "Aarav Sharma", email: "aarav@tourease.com",
                                 role: .tourist, profileImageURL: nil, provider: .email))
        .environment(SessionManager())
}
