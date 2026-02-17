import SwiftUI

struct Feature1DayInfoView: View {
    @ObservedObject var viewModel: Feature1DayInfoVM

    var body: some View {
        VStack(spacing: 0) {
            headerView()
            ScrollView {
                infoSectionView()
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                recordsListView()
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.palette(.backColor))
        .navigationBarBackButtonHidden()
        .onAppear {
            Task { await viewModel.loadDayData() }
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Text(viewModel.selectedDate.dayMonthYearString())
                .typography(.body.semibold)
                .foregroundStyle(Color.palette(.textPrimary))
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topLeading) {
            Button {
                viewModel.onBackTapped()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.palette(.black900))
                    .padding(.leading, 16)
            }
        }
    }

    @ViewBuilder
    private func infoSectionView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total:")
                    .font(.body)
                    .foregroundStyle(Color.palette(.black900))
                Spacer()
                Text("\(viewModel.generalinfo.total) mm")
                    .foregroundStyle(Color.palette(.blueColor))
            }
            .frame(height: 44)

            Divider()

            HStack {
                Text("Rain Falls:")
                    .font(.body)
                    .foregroundStyle(Color.palette(.black900))
                Spacer()
                Text("\(viewModel.generalinfo.rainFalls)")
                    .foregroundStyle(Color.palette(.blueColor))
            }
            .frame(height: 44)

            Divider()

            HStack {
                Text("Average:")
                    .font(.body)
                    .foregroundStyle(Color.palette(.black900))
                Spacer()
                Text("\(viewModel.generalinfo.average) mm")
                    .foregroundStyle(Color.palette(.blueColor))
            }
            .frame(height: 44)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.palette(.white))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func recordsListView() -> some View {
        VStack(spacing: 12) {
            ForEach(viewModel.dayRecords) { record in
                Button {
                    viewModel.onRecordTapped(record)
                } label: {
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
    Feature1DayInfoView(viewModel: Feature1DayInfoVM(service: Feature1Service(), selectedDate: Date()))
}
