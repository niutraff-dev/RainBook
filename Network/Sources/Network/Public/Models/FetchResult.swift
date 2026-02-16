import Foundation

public enum FetchResult: Sendable, Equatable {
    case success
    case badRequest
    case otherError
}
