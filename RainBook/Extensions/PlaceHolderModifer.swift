import SwiftUI

extension View {
    func placeholder(
        showPlaceHolder: Bool,
        placeholder: String,
        alignment: Alignment = .leading,
        trailingPadding: CGFloat = 0,
        leadingPadding: CGFloat = 0
    ) -> some View {
        modifier(
            PlaceholderStyle(
                showPlaceHolder: showPlaceHolder,
                placeholder: placeholder,
                alignment: alignment,
                trailingPadding: trailingPadding,
                leadingPadding: leadingPadding
            )
        )
    }
}

fileprivate struct PlaceholderStyle: ViewModifier {
    let showPlaceHolder: Bool
    let placeholder: String
    let alignment: Alignment
    let trailingPadding: CGFloat
    let leadingPadding: CGFloat

    public func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            if showPlaceHolder {
                Text(placeholder)
                    .font(.system(size: 17))
                    .foregroundColor(Color.gray)
                    .padding(.trailing, trailingPadding)
                    .padding(.leading, leadingPadding)
            }
            content
        }
    }
}
