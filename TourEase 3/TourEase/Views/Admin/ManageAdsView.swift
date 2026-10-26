import SwiftUI
import SwiftData

struct ManageAdsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AdBanner.sortOrder) private var banners: [AdBanner]

    @State private var showUploadSheet = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 12) {
                    PrimaryButton(title: "Upload New Banner") { showUploadSheet = true }

                    if banners.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "rectangle.stack.badge.plus").font(.system(size: 26)).foregroundStyle(Color.touroTextMuted)
                            Text("No ad banners yet. Upload one to show it on the login screen.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(Color.touroTextMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(banners) { banner in
                            BannerRow(banner: banner, onDelete: {
                                modelContext.delete(banner)
                                try? modelContext.save()
                            })
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Manage Ads")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showUploadSheet) {
            UploadBannerSheet(nextSortOrder: banners.count)
        }
    }
}

private struct BannerRow: View {
    @Bindable var banner: AdBanner
    let onDelete: () -> Void
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(banner.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.touroTextPrimary)
                    Text(banner.isCurrentlyRunning ? "Running now" : (banner.isActive ? "Scheduled" : "Paused"))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(banner.isCurrentlyRunning ? Color.touroTealLight : Color.touroTextMuted)
                }
                Spacer()
                Toggle("", isOn: $banner.isActive)
                    .labelsHidden()
                    .tint(.touroTeal)
                    .onChange(of: banner.isActive) { _, _ in try? modelContext.save() }
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash").foregroundStyle(Color.touroSunset)
                }
                .accessibilityLabel("Delete banner")
            }

            HStack(spacing: 6) {
                Image(systemName: "calendar").font(.system(size: 10.5)).foregroundStyle(Color.touroTextMuted)
                Text("\(banner.startDate.formatted(date: .abbreviated, time: .omitted)) – \(banner.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 10.5, design: .rounded))
                    .foregroundStyle(Color.touroTextMuted)
            }
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}

private struct UploadBannerSheet: View {
    let nextSortOrder: Int
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var imageURLString = ""
    @State private var startDate = Date.now
    @State private var endDate = Date.now.addingTimeInterval(60 * 60 * 24 * 14)
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 16) {
                Capsule().fill(Color.white.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 10)

                Text("Upload Banner")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                GlassCard {
                    VStack(spacing: 14) {
                        FloatingTextField(title: "Banner title", systemImage: "text.alignleft", text: $title)
                        FloatingTextField(title: "Image URL", systemImage: "photo.fill", text: $imageURLString, keyboardType: .URL)

                        DatePicker("Starts", selection: $startDate, displayedComponents: .date)
                            .tint(.touroTeal).foregroundStyle(Color.touroTextPrimary)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 14))

                        DatePicker("Ends", selection: $endDate, displayedComponents: .date)
                            .tint(.touroTeal).foregroundStyle(Color.touroTextPrimary)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 14))

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12.5, design: .rounded))
                                .foregroundStyle(Color.touroSunset)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        PrimaryButton(title: "Upload") { upload() }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func upload() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Give the banner a title."
            return
        }
        guard endDate >= startDate else {
            errorMessage = "End date must be after the start date."
            return
        }
        let banner = AdBanner(title: title, imageURLString: imageURLString, startDate: startDate, endDate: endDate, sortOrder: nextSortOrder)
        modelContext.insert(banner)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack { ManageAdsView() }
}
