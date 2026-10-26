import SwiftUI

struct EmergencyContact: Identifiable {
    let id = UUID()
    let title: String
    let number: String
    let systemImage: String
    let tint: Color
}

/// Fully functional (not a placeholder) — simple enough to ship in the
/// Dashboard module rather than waiting on a dedicated module. Tapping a
/// contact opens the Phone app via `tel:`; on Simulator this will just fail
/// silently (no Phone app), which is expected.
struct EmergencyView: View {
    private let contacts: [EmergencyContact] = [
        .init(title: "Police", number: "100", systemImage: "shield.lefthalf.filled", tint: .blue),
        .init(title: "Ambulance", number: "108", systemImage: "cross.case.fill", tint: .red),
        .init(title: "Fire Department", number: "101", systemImage: "flame.fill", tint: .orange),
        .init(title: "Women's Helpline", number: "1091", systemImage: "person.fill.and.arrow.left.and.arrow.right", tint: .pink),
        .init(title: "Tourist Helpline", number: "1363", systemImage: "figure.wave", tint: Color.touroTeal),
        .init(title: "National Emergency", number: "112", systemImage: "exclamationmark.triangle.fill", tint: .yellow),
    ]

    var body: some View {
        ZStack {
            AnimatedBackground()
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.touroSunset)
                        Text("In an emergency, tap a contact to call.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 40)

                    VStack(spacing: 12) {
                        ForEach(contacts) { contact in
                            Button {
                                call(contact.number)
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle().fill(contact.tint.opacity(0.2)).frame(width: 46, height: 46)
                                        Image(systemName: contact.systemImage)
                                            .foregroundStyle(contact.tint)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contact.title)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.touroTextPrimary)
                                        Text(contact.number)
                                            .font(.system(size: 12.5, design: .rounded))
                                            .foregroundStyle(Color.touroTextMuted)
                                    }
                                    Spacer()
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundStyle(Color.touroTealLight)
                                }
                                .padding(14)
                                .glassCardStyle(cornerRadius: 18)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Emergency")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private func call(_ number: String) {
        guard let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack { EmergencyView() }
}
