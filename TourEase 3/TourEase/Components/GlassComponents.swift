import SwiftUI
import UIKit
import Combine

/// Frosted floating card — the base container for auth forms, dashboard cards, etc.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .glassCardStyle(cornerRadius: cornerRadius)
    }
}

/// Pill-shaped floating text field matching the reference login-page style.
struct FloatingTextField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var isSecure: Bool = false
    var isPasswordVisible: Bool = true
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.touroTextMuted)
                .frame(width: 20)

            Group {
                if isSecure && !isPasswordVisible {
                    SecureField("", text: $text, prompt: Text(title).foregroundColor(.touroTextMuted))
                } else {
                    TextField("", text: $text, prompt: Text(title).foregroundColor(.touroTextMuted))
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .foregroundStyle(Color.touroTextPrimary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(.white.opacity(0.06))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.touroGlassStroke, lineWidth: 1))
    }
}

/// Primary gradient CTA button with built-in loading spinner state.
struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var gradient: LinearGradient = .touroCTA
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(gradient)
        .foregroundStyle(.white)
        .clipShape(Capsule())
        .shadow(color: Color.touroTeal.opacity(0.35), radius: 16, x: 0, y: 8)
        .disabled(isLoading)
        .opacity(isLoading ? 0.85 : 1)
    }
}

/// Social sign-in button (Google / Apple) — outlined glass pill with logo + label.
struct SocialButton: View {
    let title: String
    let systemImage: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: systemImage)
                    Text(title).font(.system(size: 15, weight: .medium, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .background(.white.opacity(0.06))
        .foregroundStyle(.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.touroGlassStroke, lineWidth: 1))
        .disabled(isLoading)
    }
}

/// Reserved ad banner slot at the top of the Login screen.
/// Cycles through active `AdBanner`s (managed from the Admin Portal's
/// Manage Ads screen) and loads each banner's image through
/// `AdBannerImageCaching`, which caches to disk so a previously-seen
/// banner still renders offline.
struct AdBannerSlot: View {
    var banners: [AdBanner] = []
    var imageCache: AdBannerImageCaching = AdBannerImageCache.shared
    @State private var index = 0
    @State private var imageData: Data?
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    private var currentBanner: AdBanner? { banners.isEmpty ? nil : banners[index] }

    var body: some View {
        GlassCard(cornerRadius: 18) {
            HStack(spacing: 10) {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    Image(systemName: "megaphone.fill").foregroundStyle(Color.touroTealLight)
                }

                Text(currentBanner?.title ?? "Sponsored spot — Admin Portal → Manage Ads")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(currentBanner == nil ? Color.touroTextMuted : Color.touroTextPrimary)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 24)
        .task(id: currentBanner?.id) {
            imageData = nil
            guard let banner = currentBanner else { return }
            imageData = await imageCache.loadImageData(id: banner.id, imageURLString: banner.imageURLString)
        }
        .onReceive(timer) { _ in
            guard !banners.isEmpty else { return }
            withAnimation { index = (index + 1) % banners.count }
        }
    }
}
