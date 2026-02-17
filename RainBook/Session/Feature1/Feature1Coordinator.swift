import SwiftUI
import Combine

@MainActor
protocol Feature1CoordinatorElementsFactory {
    func feature1VM() -> Feature1VM
    func feature1DayInfoVM(selectedDate: Date) -> Feature1DayInfoVM
    func feature1DetailVM(existingRecord: WeatherData?) -> Feature1DetailVM
}

@MainActor
final class Feature1Coordinator: ObservableObject {

    let navigation: Feature1CoordinatorNavigation
    private let elementsFactory: Feature1CoordinatorElementsFactory
    private var _viewModel: Feature1VM?

    private var viewModel: Feature1VM {
        if let vm = _viewModel { return vm }
        let vm = elementsFactory.feature1VM()
        vm.output = .init(
            onDetail: { [weak self] in self?.showDetail(editing: nil) },
            onDateSelected: { [weak self] date in self?.showDayInfo(date: date) }
        )
        _viewModel = vm
        return vm
    }

    init(
        navigation: Feature1CoordinatorNavigation,
        elementsFactory: Feature1CoordinatorElementsFactory
    ) {
        self.navigation = navigation
        self.elementsFactory = elementsFactory
    }

    func showMain() -> some View {
        navigation.view(for: .main(viewModel))
    }

    private func showDayInfo(date: Date) {
        let dayInfoVM = elementsFactory.feature1DayInfoVM(selectedDate: date)
        dayInfoVM.output = .init(
            onBack: { [weak self] in self?.navigation.navigateBack() },
            onEdit: { [weak self] record in self?.showDetail(editing: record) }
        )
        navigation.navigateTo(.dayInfo(dayInfoVM))
    }

    private func showDetail(editing existingRecord: WeatherData? = nil) {
        let detailVM = elementsFactory.feature1DetailVM(existingRecord: existingRecord)
        let mainVM = viewModel
        detailVM.output = .init(
            onBack: { [weak self] in
                Task { @MainActor in
                    await mainVM.loadDatesWithRecords()
                    self?.navigation.navigateBack()
                }
            }
        )
        navigation.navigateTo(.detail(detailVM))
    }
}
