import SwiftUI

struct Feature2View: View {

    @ObservedObject var viewModel: Feature2VM

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                recordsListView()
                    .padding(.top)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.palette(.backColor))
        .navigationView(title: "History")
    }
    
    @ViewBuilder
    private func recordsListView() -> some View {
        VStack(spacing: 12) {
            ForEach(viewModel.records) { record in
                Button {
                    viewModel.onRecordTapped(record)
                } label: {
                    VStack {
                        HStack(alignment: .center, spacing: 12) {
                            Image(record.weather.image)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.weather.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.palette(.textPrimary))
                                Text("\(record.date.dateToString()) at \(record.time.timeToString())")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.palette(.textSecondary))
                                Text("\(record.rainFall) mm")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.palette(.blueColor))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.palette(.textSecondary))
                        }
                        if !record.notes.isEmpty {
                            Divider()
                            
                            Text(record.notes)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.palette(.textSecondary))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.palette(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Feature2View(viewModel: Feature2VM(service: .init()))
    }
}
