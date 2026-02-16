import SwiftUI

struct Feature1CalendarView: View {
    
    @ObservedObject var viewModel: Feature1VM
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private static let weekdaySymbols = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    private static var monthYearFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale.current
        return f
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            weekdayRow
            dayGrid
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.palette(.white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var header: some View {
        HStack {
            Text(Self.monthYearFormatter.string(from: viewModel.displayedMonth))
                .typography(.headline.semibold)
                .foregroundStyle(Color.palette(.textPrimary))
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    viewModel.previousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.palette(.blueColor))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.nextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.palette(.blueColor))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 16)
    }
    
    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .typography(.caption1.regular)
                    .foregroundStyle(Color.palette(.textSecondary))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 12)
    }
    
    private var dayGrid: some View {
        let days = daysForDisplayedMonth()
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<days.count, id: \.self) { index in
                dayCell(day: days[index], index: index, days: days)
            }
        }
    }
    
    private func dayCell(day: Int?, index: Int, days: [Int?]) -> some View {
        let monthStart = viewModel.displayedMonth
        let date: Date? = day.flatMap { viewModel.date(for: $0, in: monthStart) }
        let isSelected: Bool = {
            guard let sel = viewModel.selectedDate, let d = date else { return false }
            return calendar.isDate(sel, inSameDayAs: d)
        }()
        let hasRecord: Bool = {
            guard let d = date else { return false }
            return viewModel.datesWithRecords.contains(calendar.startOfDay(for: d))
        }()
        
        return Group {
            if let day = day {
                Button {
                    if let d = date {
                        viewModel.onDateTapped(d)
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text("\(day)")
                            .typography(.title3.semibold)
                            .foregroundStyle(isSelected ? Color.palette(.white) : Color.palette(.textPrimary))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                isSelected
                                ? Color.palette(.blueColor)
                                : Color.clear
                            )
                            .clipShape(Circle())
                        ZStack {
                            if hasRecord {
                                Circle()
                                    .fill(Color.palette(.blueColor))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(height: 8)
                    }
                    .frame(height: 48)
                }
                .buttonStyle(.plain)
            } else {
                Text("")
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
        }
    }
    
    private func daysForDisplayedMonth() -> [Int?] {
        let monthStart = viewModel.displayedMonth
        let firstWeekday = calendar.component(.weekday, from: monthStart) // 1 = Sunday
        let leadingBlanks = firstWeekday - 1
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let lastDay = range.upperBound - range.lowerBound
        
        let totalCells = leadingBlanks + lastDay
        let numberOfRows = (totalCells + 6) / 7
        let totalGridCells = numberOfRows * 7
        
        var days: [Int?] = []
        for _ in 0..<leadingBlanks { days.append(nil) }
        for d in 1...lastDay { days.append(d) }
        while days.count < totalGridCells { days.append(nil) }
        return days
    }
}
