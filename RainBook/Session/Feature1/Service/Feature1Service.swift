import Foundation
import Combine

enum Feature1ServiceError: Error, LocalizedError {
    case decodingFailed(Error)
    case encodingFailed(Error)
    case invalidIndex(Int)
    case storageFailure(Error)
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed(let error):
            return "Failed to decode info: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode info: \(error.localizedDescription)"
        case .invalidIndex(let index):
            return "Invalid index for deletion: \(index)"
        case .storageFailure(let error):
            return "Storage operation failed: \(error.localizedDescription)"
        }
    }
}

protocol Feature1Repository {
    var recordsPublisher: AnyPublisher<Result<[WeatherData], Feature1ServiceError>, Never> { get }
    func loadRecords() throws -> [WeatherData]
    func saveRecord(_ info: [WeatherData]) throws
}

final class KeyValueRecordsRepository: Feature1Repository {
    private let storage: DefaultsStorage
    
    private let recordSubject = PassthroughSubject<Result<[WeatherData], Feature1ServiceError>, Never>()
    
    var recordsPublisher: AnyPublisher<Result<[WeatherData], Feature1ServiceError>, Never> {
        recordSubject.eraseToAnyPublisher()
    }
    
    init(storage: DefaultsStorage = DefaultsStorage()) {
        self.storage = storage
    }
    
    func loadRecords() throws -> [WeatherData] {
        guard let data = storage.data(forKey: .record_data) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([WeatherData].self, from: data)
        } catch {
            throw Feature1ServiceError.decodingFailed(error)
        }
    }
    
    func saveRecord(_ info: [WeatherData]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(info)
            storage.set(data, forKey: .record_data)
            recordSubject.send(.success(info))
        } catch {
            throw Feature1ServiceError.encodingFailed(error)
        }
    }
}

actor Feature1Service {
    nonisolated var recordsPublisher: AnyPublisher<Result<[WeatherData], Feature1ServiceError>, Never> { recordsSubject.eraseToAnyPublisher() }
    
    private var records: [WeatherData] = []
    private var cancellables = Set<AnyCancellable>()
    private let repository: Feature1Repository
    private let recordsSubject = CurrentValueSubject<Result<[WeatherData], Feature1ServiceError>, Never>(.success([]))
    
    init(repository: Feature1Repository = KeyValueRecordsRepository()) {
        self.repository = repository
        Task { await setupRepositorySubscription() }
        Task { await loadRecords() }
    }
    
    private func setupRepositorySubscription() {
        repository.recordsPublisher
            .sink { [weak self] info in
                Task { [weak self] in
                    await self?.updateRecordsSubject(info)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateRecordsSubject(_ result: Result<[WeatherData], Feature1ServiceError>) {
        recordsSubject.send(result)
        if case .success(let records) = result {
            self.records = records
        }
    }
    
    private func loadRecords() {
        do {
            let loadedInfo = try repository.loadRecords()
            self.records = loadedInfo
            recordsSubject.send(.success(records))
        } catch {
            recordsSubject.send(.failure(Feature1ServiceError.storageFailure(error)))
        }
    }
    
    func getRecords() async -> [WeatherData] {
        records
    }

    func saveRecord(_ result: WeatherData) async {
        do {
            var latest = try repository.loadRecords()
            if let index = latest.firstIndex(where: { $0.id == result.id }) {
                latest[index] = result
            } else {
                latest.append(result)
            }
            try repository.saveRecord(latest)
            self.records = latest
            recordsSubject.send(.success(latest))
        } catch {
            recordsSubject.send(.failure(Feature1ServiceError.storageFailure(error)))
        }
    }

    func deleteRecord(id: String) async {
        do {
            var latest = try repository.loadRecords()
            latest.removeAll { $0.id == id }
            try repository.saveRecord(latest)
            self.records = latest
            recordsSubject.send(.success(latest))
        } catch {
            recordsSubject.send(.failure(Feature1ServiceError.storageFailure(error)))
        }
    }
}





