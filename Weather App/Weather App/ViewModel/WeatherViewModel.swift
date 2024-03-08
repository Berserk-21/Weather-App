//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

final class WeatherViewModel {
    
    // MARK: - Properties
    
    private let weatherService: OpenWeatherService
    
    // BehaviosSubject emits an initial value (what is set in the instanciation).
    // PublishSubject emits only value after the subscription is made.
//    var weatherForecast: BehaviorSubject<WeatherForecast?> = BehaviorSubject(value: nil)
    var weatherForecast: PublishSubject<WeatherForecastModel> = PublishSubject()
    
    private var disposeBag = DisposeBag()
    
    let temperatureFormatter = NumberFormatter()
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    lazy var currentTemperature: Observable<String>? = {
        return weatherForecast
            .compactMap { [weak self] in
                self?.formatTemperature($0.current.temperature_2m)
            }
            .asObservable()
    }()
    
    lazy var minMaxTemperature: Observable<String>? = {
        return weatherForecast
            .compactMap { [weak self] in
                self?.formatExtremeTemperatures(from: $0)
            }
            .asObservable()
    }()
    
    lazy var weatherCodeString: Observable<String>? = {
        return weatherForecast
            .compactMap { [weak self] in
                self?.descriptionForWeatherCode($0.current.weather_code)
            }
            .asObservable()
    }()
    
    lazy var backgroundImage: Observable<UIImage>? = {
        return weatherForecast
            .compactMap { [weak self] in
                self?.getBackgroundImageForWeatherCode($0.current.weather_code)
            }
            .asObservable()
    }()
    
    lazy var cityString: Observable<String>? = {
        return weatherForecast
            .compactMap { _ in
                return "Montpellier"
            }
            .asObservable()
    }()
    
    let localizeUserAction = PublishSubject<Void>()
    
    init() {
        weatherService = OpenWeatherService()
        
        fetchWeatherData()
        bindActions()
    }
    
    func bindActions() {
        
        localizeUserAction.subscribe(onNext: { [weak self] in
            self?.fetchGeolocalization()
        })
        .disposed(by: disposeBag)
    }
    
    func fetchGeolocalization() {
        
        print("fetchGeolocalization")
    }
    
    // Fetch weather forecast in a property, the views must observe it to get forecast events.
    func fetchWeatherData() {
        
        isLoading.onNext(true)
        
        weatherService.fetchWeatherForecast()
            .subscribe { [weak self] forecast in
                self?.weatherForecast.onNext(forecast)
                self?.isLoading.onNext(false)
            } onError: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.error.onNext(error)
            } onCompleted: { [weak self] in
                self?.isLoading.onNext(false)
            }
            .disposed(by: disposeBag)
    }
    
    private func descriptionForWeatherCode(_ code: Int) -> String {
        switch code {
        case 0:
            return "Clear sky"
        case 1...3:
            return "Partly cloudy"
        case 4:
            return "Overcast"
        case 10, 20...29, 45, 48:
            return "Mist"
        case 50...69, 80...99:
            return "Rain"
        case 70...79:
            return "Snowfall"
        default:
            return "Unknown weather condition"
        }
    }
    
    private func getBackgroundImageForWeatherCode(_ code: Int) -> UIImage? {
        
        switch code {
        case 0:
            return UIImage(named: "clear_sky")
        case 1...3:
            return UIImage(named: "partly_cloudy")
        case 4:
            return UIImage(named: "overcast")
        case 10, 20...29, 45, 48:
            return UIImage(named: "mist")
        case 50...69, 80...99:
            return UIImage(named: "rainy")
        case 70...79:
            return UIImage(named: "snowfall")
        default:
            return UIImage(named: "moon")
        }
    }
    
    private func formatTemperature(_ temperature: CGFloat) -> String? {
        temperatureFormatter.roundingMode = .halfDown
        temperatureFormatter.maximumFractionDigits = 0
        
        return temperatureFormatter.string(from: NSNumber(floatLiteral: temperature))
    }
    
    private func formatExtremeTemperatures(from forecast: WeatherForecastModel) -> String {
        
        var string = ""
        
        if let maxTemp = forecast.hourly.maxTemperature, let maxTempString = formatTemperature(maxTemp) {
            string += "↑\(maxTempString)°"
        }
        
        if let minTemp = forecast.hourly.minTemperature, let minTempString = formatTemperature(minTemp) {
            if !string.isEmpty {
                string += " "
            }
            
            string += "↓\(minTempString)°"
        }
        
        return string
    }
    
//    private func weatherCodeInterpretation(from code: Int) -> String {
//        switch code {
//        case 0:
//            return "Clear"
//        case 1:
//            return "Mostly Clear"
//        case 2:
//            return "Partly Cloudy"
//        case 3:
//            return "Cloudy"
//        case 45:
//            return "Fog"
//        case 48:
//            return "Freezing Fog"
//        case 51:
//            return "Light Drizzle"
//        case 53:
//            return "Drizzle"
//        case 55:
//            return "Heavy Drizzle"
//        case 56:
//            return "Light Freezing Drizzle"
//        case 57:
//            return "Freezing Drizzle"
//        case 61:
//            return "Light Rain"
//        case 63:
//            return "Rain"
//        case 65:
//            return "Heavy Rain"
//        case 66:
//            return "Light Freezing Rain"
//        case 67:
//            return "Freezing Rain"
//        case 71:
//            return "Light Snow"
//        case 73:
//            return "Snow"
//        case 75:
//            return "Heavy Snow"
//        case 77:
//            return "Snow Grains"
//        case 80:
//            return "Light Rain Shower"
//        case 81:
//            return "Rain Shower"
//        case 82:
//            return "Heavy Rain Shower"
//        case 85:
//            return "Snow Shower"
//        case 86:
//            return "Heavy Snow Shower"
//        case 95:
//            return "Thunderstorm"
//        case 96:
//            return "Hailstorm"
//        case 99:
//            return "Heavy Hailstorm"
//        default:
//            return "Unknown weather code"
//        }
//
//    }
}
