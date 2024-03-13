//
//  WeatherForecast.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import Foundation

struct OpenWeatherModel: Decodable {
    
    let latitude: Double
    let longitude: Double
    let generationtime_ms: Double
    let utc_offset_seconds: Int
    let timezone: String
    let timezone_abbreviation: String
    let elevation: CGFloat
    let hourly_units: HourlyUnits
    let hourly: HourlyWeather
    let current_units: CurrentUnits
    let current: CurrentWeather
}

struct CurrentUnits: Decodable {
    let time: String
    let interval: String
    let weather_code: String
    let temperature_2m: String
}

struct CurrentWeather: Decodable {
    let time: String
    let interval: Int
    let temperature_2m: CGFloat
    let weather_code: Int
}

struct HourlyUnits: Decodable {
    let time: String
    let temperature_2m: String
}

struct HourlyWeather: Decodable {
    let time: [String]
    let temperature_2m: [Double]
    
    var maxTemperature: Double? {
        return temperature_2m.max()
    }
    
    var minTemperature: Double? {
        return temperature_2m.min()
    }
}
