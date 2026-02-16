import Foundation
import Combine

@MainActor
final class Feature2VM: ObservableObject {

    struct Output {
        let onEditRecord: (WeatherData) -> Void
    }
    
    @Published
    var records: [WeatherData] = []

    var output: Output?
    
    private let service: Feature1Service
    private var cancellables = Set<AnyCancellable>()
    
    init(service: Feature1Service) {
        self.service = service
        subscribeToRecords()
    }
    
    private func subscribeToRecords() {
        service.recordsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let info):
                    self?.records = info
                case .failure(let error):
                    print(error.errorDescription ?? "Unknown error")
                }
            }
            .store(in: &cancellables)
    }

    func onRecordTapped(_ record: WeatherData) {
        output?.onEditRecord(record)
    }
}
