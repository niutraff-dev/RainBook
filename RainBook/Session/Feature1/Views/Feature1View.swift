import SwiftUI

struct Feature1View: View {

    @ObservedObject var viewModel: Feature1VM

    var body: some View {
        VStack {
            Feature1CalendarView(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.top, 24)

            Button {
                viewModel.onDetailTapped()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Weather")
                        .typography(.body.semibold)
                }
                .foregroundStyle(Color.palette(.white))
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                .background(Color.palette(.blueColor))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(.plain)
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.palette(.backColor))
        .navigationView(title: "Calendar", showsBackButton: false)
        .task {
            await viewModel.loadDatesWithRecords()
        }
    }
}

#Preview {
    NavigationStack {
        Feature1View(viewModel: Feature1VM(service: .init()))
    }
}
