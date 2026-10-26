import SwiftUI

struct AdminPortalView: View {
    let user: AppUser
    @Environment(SessionManager.self) private var session
    @State private var path: [AdminDestination] = []

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AnimatedBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        header

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(AdminDestination.allCases) { destination in
                                Button {
                                    path.append(destination)
                                } label: {
                                    AdminCard(title: destination.title, subtitle: destination.subtitle, systemImage: destination.systemImage)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        PrimaryButton(title: "Log Out", gradient: .touroAccentCTA) {
                            session.signOut()
                        }
                        .padding(.horizontal, 60)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(for: AdminDestination.self) { destination in
                switch destination {
                case .manageUsers: ManageUsersView()
                case .manageAds: ManageAdsView()
                case .hotelPricing: ManageHotelPricingView()
                case .foodPricing: ManageFoodPricingView()
                case .transportPricing: ManageTransportPricingView()
                case .analytics: AdminAnalyticsView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "shield.checkerboard").foregroundStyle(Color.touroSunset)
                Text("Admin Portal")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroSunset)
            }
            Text(user.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

enum AdminDestination: String, CaseIterable, Identifiable {
    case manageUsers, manageAds, hotelPricing, foodPricing, transportPricing, analytics
    var id: String { rawValue }

    var title: String {
        switch self {
        case .manageUsers: return "Manage Users"
        case .manageAds: return "Manage Ads"
        case .hotelPricing: return "Hotel Pricing"
        case .foodPricing: return "Food Pricing"
        case .transportPricing: return "Transport Pricing"
        case .analytics: return "Analytics"
        }
    }

    var subtitle: String {
        switch self {
        case .manageUsers: return "Suspend or delete"
        case .manageAds: return "Banners & schedule"
        case .hotelPricing: return "Edit nightly rates"
        case .foodPricing: return "Edit meal averages"
        case .transportPricing: return "Edit fares"
        case .analytics: return "Trip statistics"
        }
    }

    var systemImage: String {
        switch self {
        case .manageUsers: return "person.2.fill"
        case .manageAds: return "rectangle.stack.fill"
        case .hotelPricing: return "bed.double.fill"
        case .foodPricing: return "fork.knife"
        case .transportPricing: return "car.fill"
        case .analytics: return "chart.bar.fill"
        }
    }
}

#Preview {
    AdminPortalView(user: AppUser(id: "1", name: "Ishaan Verma", email: "ishaan.admin@tourease.com",
                                   role: .admin, profileImageURL: nil, provider: .email))
        .environment(SessionManager())
}
