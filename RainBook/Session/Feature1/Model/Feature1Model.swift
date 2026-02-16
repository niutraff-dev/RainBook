import Foundation

struct WeatherData: Identifiable, Codable {
    var id = UUID().uuidString
    var weather: Weather
    var rainFall: String
    var date: Date
    var time: Date
    var notes: String
}

extension WeatherData {
    static let initialInfo: WeatherData = .init(weather: .snow, rainFall: "", date: .now, time: .now, notes: "")

    var isValid: Bool {
        rainFall.isEmpty
    }
}

struct Weather: Codable, Equatable {
    var name: String
    var iconName: String
    var image: String
}

struct GeneralInfo {
    var total: Int
    var rainFalls: Int
    var average: Int
}

extension Weather {
    static let snow: Weather = .init(
        name: "Snow",
        iconName: "im1",
        image: "weth1"
    )
    
    static let storm: Weather = .init(
        name: "Storm",
        iconName: "im2",
        image: "weth2"
    )
    
    static let cloudy: Weather = .init(
        name: "Cloudy",
        iconName: "im3",
        image: "weth3"
    )
    
    static let rainy: Weather = .init(
        name: "Rainy",
        iconName: "im4",
        image: "weth4"
    )
    
    static let clear: Weather = .init(
        name: "Clear",
        iconName: "im5",
        image: "weth5"
    )
    
    static let sunny: Weather = .init(
        name: "Sunny",
        iconName: "im6",
        image: "weth6"
    )
    
    static let hot: Weather = .init(
        name: "Hot",
        iconName: "im7",
        image: "weth7"
    )
}
