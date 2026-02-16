import XCTest
@testable import Network

final class Base64DecoderTests: XCTestCase {

    func test_decodesValidHTTPSURL() {
        let url = "https://example.com/path"
        let base64 = Data(url.utf8).base64EncodedString()

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertEqual(result?.absoluteString, url)
    }

    func test_decodesValidHTTPURL() {
        let url = "http://example.com"
        let base64 = Data(url.utf8).base64EncodedString()

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertEqual(result?.absoluteString, url)
    }

    func test_decodesURLWithQueryParams() {
        let url = "https://example.com/path?key=value&foo=bar"
        let base64 = Data(url.utf8).base64EncodedString()

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertEqual(result?.absoluteString, url)
    }

    func test_decodesFromData() {
        let url = "https://example.com"
        let base64Data = Data(url.utf8).base64EncodedData()

        let result = Base64Decoder.decodeURL(from: base64Data)

        XCTAssertEqual(result?.absoluteString, url)
    }

    func test_handlesBase64WithoutPadding() {
        let url = "https://a.com"
        var base64 = Data(url.utf8).base64EncodedString()
        base64 = base64.replacingOccurrences(of: "=", with: "")

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertEqual(result?.absoluteString, url)
    }

    func test_returnsNilForInvalidBase64() {
        let invalid = "not-valid-base64!!!"

        let result = Base64Decoder.decodeURL(from: invalid)

        XCTAssertNil(result)
    }

    func test_returnsNilForNonURLContent() {
        let text = "this is not a url"
        let base64 = Data(text.utf8).base64EncodedString()

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertNil(result)
    }

    func test_returnsNilForEmptyString() {
        let empty = ""

        let result = Base64Decoder.decodeURL(from: empty)

        XCTAssertNil(result)
    }

    func test_returnsNilForFTPURL() {
        let url = "ftp://example.com"
        let base64 = Data(url.utf8).base64EncodedString()

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertNil(result, "FTP URLs should not be allowed")
    }

    func test_returnsNilForFileURL() {
        let url = "file:///path/to/file"
        let base64 = Data(url.utf8).base64EncodedString()

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertNil(result, "File URLs should not be allowed")
    }

    func test_handlesWhitespaceAroundBase64() {
        let url = "https://example.com"
        let base64 = "  " + Data(url.utf8).base64EncodedString() + "  \n"

        let result = Base64Decoder.decodeURL(from: base64)

        XCTAssertEqual(result?.absoluteString, url)
    }
}
