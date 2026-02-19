import Combine
import Foundation

@MainActor
final class Feature1VM: ObservableObject {

    struct Output {
        let onDetail: () -> Void
        let onDateSelected: (Date) -> Void
    }

    var output: Output?

    @Published private(set) var displayedMonth: Date
    @Published private(set) var selectedDate: Date?
    @Published private(set) var datesWithRecords: Set<Date> = []

    private let calendar: Calendar
    private let service: Feature1Service

    init(service: Feature1Service, calendar: Calendar? = nil) {
        self.service = service
        let cal = calendar ?? {
            var c = Calendar(identifier: .gregorian)
            c.firstWeekday = 1
            return c
        }()
        self.calendar = cal
        self.displayedMonth = cal.startOfMonth(for: Date())
    }

    func loadDatesWithRecords() async {
        let records = await service.getRecords()
        datesWithRecords = Set(records.map { calendar.startOfDay(for: $0.date) })
    }

    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = calendar.startOfMonth(for: newMonth)
        }
    }

    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = calendar.startOfMonth(for: newMonth)
        }
    }

    func selectDate(_ date: Date?) {
        selectedDate = date
    }

    func onDateTapped(_ date: Date) {
        selectDate(date)
        output?.onDateSelected(date)
    }

    func date(for dayNumber: Int, in monthStart: Date) -> Date? {
        guard dayNumber >= 1 else { return nil }
        var components = calendar.dateComponents([.year, .month], from: monthStart)
        components.day = dayNumber
        guard let date = calendar.date(from: components),
              calendar.isDate(date, equalTo: monthStart, toGranularity: .month) else { return nil }
        return date
    }

    func onDetailTapped() {
        output?.onDetail()
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}
