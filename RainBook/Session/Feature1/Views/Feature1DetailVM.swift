import SwiftUI
import Combine

@MainActor
final class Feature1DetailVM: ObservableObject {

    struct Output {
        let onBack: () -> Void
    }

    @Published var weatherInfo: WeatherData = .initialInfo

    var isEditMode: Bool { existingRecordId != nil }
    
    private let existingRecordId: String?

    var weatherItems: [Weather] { [.snow, .storm, .cloudy, .rainy, .clear, .sunny, .hot] }

    var output: Output?

    private let service: Feature1Service
    private var cancellables = Set<AnyCancellable>()

    init(service: Feature1Service, existingRecord: WeatherData? = nil) {
        self.service = service
        if let record = existingRecord {
            self.weatherInfo = record
            self.existingRecordId = record.id
        } else {
            self.existingRecordId = nil
        }
    }

    func onBackTapped() {
        output?.onBack()
    }

    func selectWeather(_ weather: Weather) {
        weatherInfo.weather = weather
    }

    func updateDate(_ date: Date) {
        weatherInfo.date = date
    }

    func updateTime(_ time: Date) {
        weatherInfo.time = time
    }

    func saveAndClose() {
        Task {
            await service.saveRecord(weatherInfo)
            output?.onBack()
        }
    }

    func deleteAndClose() {
        Task {
            await service.deleteRecord(id: weatherInfo.id)
            output?.onBack()
        }
    }
}
