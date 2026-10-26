import SwiftUI

/// Text field with a live autocomplete dropdown underneath — used for the
/// Source/Destination inputs in Route Planner. Visually matches
/// `FloatingTextField` (same capsule/glass language) but adds a suggestions
/// list, so it lives as its own component rather than overloading the
/// existing one.
struct LocationSearchField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var suggestions: [PlaceSuggestion]
    var trailingAction: (() -> Void)?
    var trailingSystemImage: String?
    var trailingIsLoading: Bool = false
    let onTextChanged: (String) -> Void
    let onSelectSuggestion: (PlaceSuggestion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.touroTextMuted)
                    .frame(width: 20)

                TextField("", text: $text, prompt: Text(title).foregroundColor(.touroTextMuted))
                    .foregroundStyle(Color.touroTextPrimary)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .onChange(of: text) { _, newValue in onTextChanged(newValue) }

                if trailingIsLoading {
                    ProgressView().tint(.touroTealLight)
                } else if let trailingSystemImage, let trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: trailingSystemImage)
                            .foregroundStyle(Color.touroTealLight)
                    }
                    .accessibilityLabel("Use current location")
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(.white.opacity(0.06))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.touroGlassStroke, lineWidth: 1))

            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(suggestions) { suggestion in
                        Button {
                            onSelectSuggestion(suggestion)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .font(.system(size: 13.5, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.touroTextPrimary)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.system(size: 11.5, design: .rounded))
                                        .foregroundStyle(Color.touroTextMuted)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)

                        if suggestion.id != suggestions.last?.id {
                            Divider().background(Color.touroGlassStroke)
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.touroGlassStroke, lineWidth: 1))
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: suggestions)
    }
}
