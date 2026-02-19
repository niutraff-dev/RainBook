import Combine
import Foundation

@MainActor
final class Feature3VM: ObservableObject {

    enum ChartScope: String, CaseIterable {
        case day
        case month
        case year

        var title: String {
            switch self {
            case .day: return "Day"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
    }
    
    struct ChartListData {
        var dayItems: [(day: Int, mm: Int)] = []
        var monthItems: [(month: Int, name: String, mm: Int)] = []
        var yearItems: [(year: Int, mm: Int)] = []
        var maxListValue: Int = 1
    }

    struct Output {
        let onDetail: () -> Void
    }

    @Published var scope: ChartScope = .day
    @Published var displayedMonth: Date
    @Published var displayedYear: Int
    @Published private(set) var generalinfo: GeneralInfo = .init(total: 0, rainFalls: 0, average: 0)
    @Published private(set) var listData: ChartListData = ChartListData()

    var output: Output?

    private let calendar: Calendar
    private let service: Feature1Service
    private var allRecords: [WeatherData] = []

    init(service: Feature1Service, calendar: Calendar = .current) {
        self.service = service
        self.calendar = calendar
        let now = Date()
        self.displayedMonth = calendar.startOfMonth(for: now)
        self.displayedYear = calendar.component(.year, from: now)
    }

    func loadData() async {
        allRecords = await service.getRecords()
        updateForCurrentScope()
    }

    func setScope(_ newScope: ChartScope) {
        scope = newScope
        updateForCurrentScope()
    }

    func previousPeriod() {
        switch scope {
        case .day:
            if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                displayedMonth = calendar.startOfMonth(for: newMonth)
            }
        case .month, .year:
            displayedYear -= 1
        }
        updateForCurrentScope()
    }

    func nextPeriod() {
        switch scope {
        case .day:
            if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                displayedMonth = calendar.startOfMonth(for: newMonth)
            }
        case .month, .year:
            displayedYear += 1
        }
        updateForCurrentScope()
    }

    var navigationTitle: String {
        switch scope {
        case .day:
            return monthYearString(from: displayedMonth)
        case .month, .year:
            return "\(displayedYear)"
        }
    }

    func onDetailTapped() {
        output?.onDetail()
    }

    // MARK: - Private
    private func updateForCurrentScope() {
        switch scope {
        case .day:
            updateMonthScopeStats()
            updateDayItems()
        case .month:
            updateYearScopeStatsForMonths()
            updateMonthItems()
        case .year:
            updateYearScopeStatsForYear()
            updateYearItems()
        }
    }

    private func updateMonthScopeStats() {
        let inMonth = allRecords.filter { calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
        let rainFalls = inMonth.count
        let total = inMonth.reduce(0) { $0 + (Int($1.rainFall) ?? 0) }
        let average = rainFalls > 0 ? total / rainFalls : 0
        generalinfo = GeneralInfo(total: total, rainFalls: rainFalls, average: average)
    }

    private func updateYearScopeStatsForMonths() {
        let inYear = allRecords.filter { calendar.component(.year, from: $0.date) == displayedYear }
        let rainFalls = inYear.count
        let total = inYear.reduce(0) { $0 + (Int($1.rainFall) ?? 0) }
        let average = rainFalls > 0 ? total / rainFalls : 0
        generalinfo = GeneralInfo(total: total, rainFalls: rainFalls, average: average)
    }

    private func updateYearScopeStatsForYear() {
        let inYear = allRecords.filter { calendar.component(.year, from: $0.date) == displayedYear }
        let rainFalls = inYear.count
        let total = inYear.reduce(0) { $0 + (Int($1.rainFall) ?? 0) }
        let average = rainFalls > 0 ? total / rainFalls : 0
        generalinfo = GeneralInfo(total: total, rainFalls: rainFalls, average: average)
    }

    private func updateDayItems() {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            listData = ChartListData(dayItems: [], monthItems: [], yearItems: [], maxListValue: 1)
            return
        }
        let lastDay = range.upperBound - range.lowerBound
        var items: [(day: Int, mm: Int)] = []
        for day in 1...lastDay {
            guard let date = calendar.date(bySetting: .day, value: day, of: displayedMonth) else { continue }
            let dayRecords = allRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let mm = dayRecords.reduce(0) { $0 + (Int($1.rainFall) ?? 0) }
            items.append((day: day, mm: mm))
        }
        let maxVal = max(items.map(\.mm).max() ?? 1, 1)
        listData = ChartListData(dayItems: items, monthItems: [], yearItems: [], maxListValue: maxVal)
    }

    private func updateMonthItems() {
        let monthNames = calendar.monthSymbols
        var items: [(month: Int, name: String, mm: Int)] = []
        for month in 1...12 {
            let name = monthNames[safe: month - 1] ?? "\(month)"
            let monthRecords = allRecords.filter {
                calendar.component(.year, from: $0.date) == displayedYear &&
                calendar.component(.month, from: $0.date) == month
            }
            let mm = monthRecords.reduce(0) { $0 + (Int($1.rainFall) ?? 0) }
            items.append((month: month, name: name, mm: mm))
        }
        let maxVal = max(items.map(\.mm).max() ?? 1, 1)
        listData = ChartListData(dayItems: [], monthItems: items, yearItems: [], maxListValue: maxVal)
    }

    private func updateYearItems() {
        let yearRecords = allRecords.filter { calendar.component(.year, from: $0.date) == displayedYear }
        let mm = yearRecords.reduce(0) { $0 + (Int($1.rainFall) ?? 0) }
        let maxVal = max(mm, 1)
        listData = ChartListData(dayItems: [], monthItems: [], yearItems: [(year: displayedYear, mm: mm)], maxListValue: maxVal)
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
