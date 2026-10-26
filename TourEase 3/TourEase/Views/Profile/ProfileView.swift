import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    let user: AppUser
    @Environment(SessionManager.self) private var session
    @Environment(\.modelContext) private var modelContext

    @Query private var profileRecords: [UserProfileRecord]
    @Query private var routes: [RecentRouteRecord]
    @Query private var favorites: [FavoriteHotel]

    @State private var vm = ProfileViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    private var myProfile: UserProfileRecord? { profileRecords.first { $0.id == user.id } }

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 18) {
                    photoAndNameCard
                    statsRow
                    infoCard
                    settingsLink

                    PrimaryButton(title: "Log Out", gradient: .touroAccentCTA) {
                        session.signOut()
                    }
                    .padding(.horizontal, 60)
                    .padding(.top, 4)
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { vm.load(from: myProfile, fallbackName: user.name) }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    vm.profileImageData = data
                    vm.save(userID: user.id, existing: myProfile, context: modelContext)
                }
            }
        }
    }

    private var photoAndNameCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack {
                        if let data = vm.profileImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(LinearGradient.touroCTA)
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 34))
                                        .foregroundStyle(.white)
                                )
                        }
                        Circle()
                            .fill(Color.touroSunset)
                            .frame(width: 28, height: 28)
                            .overlay(Image(systemName: "camera.fill").font(.system(size: 12)).foregroundStyle(.white))
                            .offset(x: 32, y: 32)
                    }
                }
                .accessibilityLabel("Change profile photo")

                VStack(spacing: 10) {
                    FloatingTextField(title: "Display name", systemImage: "person.text.rectangle.fill", text: $vm.displayName)
                    HStack {
                        Image(systemName: "envelope.fill").foregroundStyle(Color.touroTextMuted).frame(width: 20)
                        Text(user.email)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.touroTextMuted)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(.white.opacity(0.04))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.touroGlassStroke, lineWidth: 1))
                }

                if vm.didSave {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.touroTealLight)
                        Text("Saved").font(.system(size: 12.5, design: .rounded)).foregroundStyle(Color.touroTealLight)
                    }
                }

                PrimaryButton(title: "Save Changes") {
                    vm.save(userID: user.id, existing: myProfile, context: modelContext)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(icon: "checkmark.seal.fill", label: "Trips Completed", value: "\(routes.count)")
            statTile(icon: "heart.fill", label: "Saved Places", value: "\(favorites.count)")
        }
        .padding(.horizontal, 20)
    }

    private func statTile(icon: String, label: String, value: String) -> some View {
        GlassCard {
            VStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(Color.touroTealLight)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 10.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var infoCard: some View {
        GlassCard {
            HStack {
                Text("Signed in with")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
                Spacer()
                Text(user.provider.rawValue.capitalized)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.touroTealLight)
            }
        }
        .padding(.horizontal, 20)
    }

    private var settingsLink: some View {
        NavigationLink {
            SettingsView(userID: user.id)
        } label: {
            HStack {
                Image(systemName: "gearshape.fill").foregroundStyle(Color.touroTealLight)
                Text("Settings")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.touroTextPrimary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Color.touroTextMuted).font(.system(size: 12))
            }
            .padding(16)
            .glassCardStyle(cornerRadius: 18)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        ProfileView(user: AppUser(id: "1", name: "Aarav Sharma", email: "aarav@tourease.com",
                                   role: .tourist, profileImageURL: nil, provider: .email))
            .environment(SessionManager())
    }
}
