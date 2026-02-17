import SwiftUI

struct Feature4DetailView: View {
    let url: URL
    let back: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headarView()
            
            SafariWebView(url: url, configuration: .minimal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.palette(.backColor))
    }
    
    @ViewBuilder
    private func headarView () -> some View {
        HStack {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.palette(.black900))
            }
            .padding(.leading, 16)
            .buttonStyle(.plain)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
        .background(Color.palette(.backColor))
    }
}

#Preview {
    Feature4DetailView(
        url: URL(string: "https://www.example.com")!,
        back: {}
    )
}
