import Foundation

enum Base64Decoder {

    static func decodeURL(from data: Data) -> URL? {
        guard let base64String = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        return decodeURL(from: base64String)
    }

    static func decodeURL(from base64String: String) -> URL? {
        let trimmed = base64String.trimmingCharacters(in: .whitespacesAndNewlines)
        let paddedString = addPaddingIfNeeded(trimmed)

        guard let decodedData = Data(base64Encoded: paddedString),
              let urlString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }

        return validateURL(urlString)
    }

    private static func addPaddingIfNeeded(_ string: String) -> String {
        let remainder = string.count % 4
        if remainder == 0 {
            return string
        }
        return string + String(repeating: "=", count: 4 - remainder)
    }

    private static func validateURL(_ urlString: String) -> URL? {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }

        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            return nil
        }

        return url
    }
}
