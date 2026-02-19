import Combine
import Foundation

@MainActor
final class Feature1DayInfoVM: ObservableObject {

    struct Output {
        let onBack: () -> Void
        let onEdit: (WeatherData) -> Void
    }

    @Published private(set) var generalinfo: GeneralInfo = .init(total: 0, rainFalls: 0, average: 0)
    @Published private(set) var dayRecords: [WeatherData] = []

    let selectedDate: Date
    var output: Output?

    private let calendar: Calendar
    private let service: Feature1Service

    init(service: Feature1Service, selectedDate: Date, calendar: Calendar = .current) {
        self.service = service
        self.selectedDate = selectedDate
        self.calendar = calendar
    }

    func loadDayData() async {
        let all = await service.getRecords()
        let forDay = all.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        dayRecords = forDay

        let rainFalls = forDay.count
        let total = forDay.reduce(0) { sum, r in sum + (Int(r.rainFall) ?? 0) }
        let average = rainFalls > 0 ? total / rainFalls : 0
        generalinfo = GeneralInfo(total: total, rainFalls: rainFalls, average: average)
    }

    func onBackTapped() {
        output?.onBack()
    }

    func onRecordTapped(_ record: WeatherData) {
        output?.onEdit(record)
    }
}
