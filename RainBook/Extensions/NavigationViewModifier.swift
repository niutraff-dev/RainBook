import SwiftUI

struct NavigationButton {
    let imageName: String?
    let text: LocalizedStringKey?
    let action: () -> Void

    init(imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.text = nil
        self.action = action
    }

    init(text: LocalizedStringKey, action: @escaping () -> Void) {
        self.imageName = nil
        self.text = text
        self.action = action
    }
}

struct NavigationViewModifier: ViewModifier {

    let title: LocalizedStringKey
    let showsBackButton: Bool
    let trailingButtons: [NavigationButton]
    let onBackButtonTap: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            NavigationBarView(
                title: title,
                showsBackButton: showsBackButton && presentationMode.wrappedValue.isPresented,
                trailingButtons: trailingButtons,
                onBack: {
                    if let callback = onBackButtonTap {
                        callback()
                    } else {
                        dismiss()
                    }
                }
            )
        }
    }
}

private struct NavigationBarView: View {

    let title: LocalizedStringKey
    let showsBackButton: Bool
    let trailingButtons: [NavigationButton]
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .typography(.body.semibold)
                .foregroundStyle(Color.palette(.textPrimary))

            HStack {
                if showsBackButton {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.palette(.primary500))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }

                Spacer()

                HStack(spacing: 12) {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { _, button in
                        Button(action: button.action) {
                            if let imageName = button.imageName {
                                Image(systemName: imageName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.palette(.primary500))
                                    .frame(width: 32, height: 32)
                            } else if let text = button.text {
                                Text(text)
                                    .typography(.body.semibold)
                                    .foregroundStyle(Color.palette(.primary500))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            Color.palette(.backColor)
                .ignoresSafeArea(edges: .top)
        )
    }
}

extension View {
    func navigationView(
        title: LocalizedStringKey,
        showsBackButton: Bool = true,
        trailingButtons: [NavigationButton] = [],
        onBackButtonTap: (() -> Void)? = nil
    ) -> some View {
        modifier(NavigationViewModifier(
            title: title,
            showsBackButton: showsBackButton,
            trailingButtons: trailingButtons,
            onBackButtonTap: onBackButtonTap
        ))
    }

    func navigationView(
        title: String,
        showsBackButton: Bool = true,
        trailingButtons: [NavigationButton] = [],
        onBackButtonTap: (() -> Void)? = nil
    ) -> some View {
        modifier(NavigationViewModifier(
            title: LocalizedStringKey(title),
            showsBackButton: showsBackButton,
            trailingButtons: trailingButtons,
            onBackButtonTap: onBackButtonTap
        ))
    }
}
