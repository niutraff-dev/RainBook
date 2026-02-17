import SwiftUI
import UIKit

struct Feature3View: View {

    @ObservedObject var viewModel: Feature3VM

    var body: some View {
        VStack(spacing: 0) {
            pickerView()
            navigationBarView()
            infoSectionView()
                .padding(.horizontal, 16)
                .padding(.top, 16)
            listView()
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.palette(.backColor))
        .navigationView(title: "Chart", showsBackButton: false)
        .task {
            await viewModel.loadData()
        }
    }

    @ViewBuilder
    private func pickerView() -> some View {
        Picker("", selection: Binding(
            get: { viewModel.scope },
            set: { viewModel.setScope($0) }
        )) {
            ForEach(Feature3VM.ChartScope.allCases, id: \.self) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .tint(Color.palette(.blueColor))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear {
            configurePickerAppearance()
        }
    }

    @ViewBuilder
    private func navigationBarView() -> some View {
        HStack {
            Button {
                viewModel.previousPeriod()
            } label: {
                Image(systemName: "arrow.left.circle")
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(Color.palette(.blueColor))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()
            Text(viewModel.navigationTitle)
                .typography(.body.semibold)
                .foregroundStyle(Color.palette(.textPrimary))
            Spacer()

            Button {
                viewModel.nextPeriod()
            } label: {
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(Color.palette(.blueColor))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.palette(.white))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 12)
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
    private func listView() -> some View {
        Group {
            switch viewModel.scope {
            case .day:
                ScrollView(showsIndicators: false) {
                    dayListContent()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .month:
                ScrollView(showsIndicators: false) {
                    monthListContent()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .year:
                yearListContent()
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.palette(.white))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private func dayListContent() -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.listData.dayItems, id: \.day) { item in
                rowView(label: "\(item.day)", mm: item.mm)
            }
        }
    }

    @ViewBuilder
    private func monthListContent() -> some View {
        VStack(spacing: 12) {
            ForEach(viewModel.listData.monthItems, id: \.month) { item in
                rowView(label: item.name, mm: item.mm)
            }
        }
    }

    @ViewBuilder
    private func yearListContent() -> some View {
        VStack(spacing: 12) {
            ForEach(viewModel.listData.yearItems, id: \.year) { item in
                rowView(label: "\(item.year)", mm: item.mm)
            }
        }
    }

    @ViewBuilder
    private func rowView(label: String, mm: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.palette(.textPrimary))
                Spacer()
                Text("\(mm.formattedWithSpace) mm")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.palette(.black900))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.palette(.lightGray))
                        .frame(height: 10)
                    let width = viewModel.listData.maxListValue > 0 ? CGFloat(mm) / CGFloat(viewModel.listData.maxListValue) * geo.size.width : 0
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.palette(.blueColor))
                        .frame(width: max(0, width), height: 10)
                }
            }
            .frame(height: 10)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }

    private func configurePickerAppearance() {
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.palette(.black900)],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        UISegmentedControl.appearance().backgroundColor = UIColor.palette(.black50)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.palette(.blueColor)
    }
}

// MARK: - Helpers
private extension Int {
    var formattedWithSpace: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

#Preview {
    NavigationStack {
        Feature3View(viewModel: Feature3VM(service: Feature1Service()))
    }
}
