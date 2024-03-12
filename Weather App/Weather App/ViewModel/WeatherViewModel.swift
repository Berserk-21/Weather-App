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
import CoreLocation
import RxCoreLocation

final class WeatherViewModel {
    
    // MARK: - Properties
    
    private let weatherService: OpenWeatherService
    private let locationManager = CLLocationManager()
    private let temperatureFormatter = NumberFormatter()

    private var disposeBag = DisposeBag()
    
    private var weatherForecast: PublishSubject<WeatherForecastModel> = PublishSubject()
    private var currentCity: PublishSubject<String> = PublishSubject()
    
    private lazy var observableWeatherData: Observable<(WeatherForecastModel, String)> = {
        return Observable.zip(weatherForecast, currentCity)
            .map { $0 }
            .share()
            .asObservable()
    }()
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    lazy var currentTemperature: Observable<String>? = {
        return observableWeatherData
            .compactMap { [weak self] in
                return self?.formatTemperature($0.0.current.temperature_2m)
            }
            .asObservable()
    }()
    
    lazy var minMaxTemperature: Observable<String>? = {
        return observableWeatherData
            .compactMap { [weak self] in
                self?.formatExtremeTemperatures(from: $0.0)
            }
            .asObservable()
    }()
    
    lazy var weatherCodeString: Observable<String>? = {
        return observableWeatherData
            .compactMap { [weak self] in
                self?.descriptionForWeatherCode($0.0.current.weather_code)
            }
            .asObservable()
    }()
    
    lazy var backgroundImage: Observable<UIImage>? = {
        return observableWeatherData
            .compactMap { [weak self] in
                self?.getBackgroundImageForWeatherCode($0.0.current.weather_code)
            }
            .asObservable()
    }()
    
    lazy var cityString: Observable<String>? = {
        return observableWeatherData
            .compactMap { $0.1 }
            .asObservable()
    }()
    
    let localizeUserAction = PublishSubject<Void>()
    
    init() {
        weatherService = OpenWeatherService()
        
        bindActions()
        setupLocationManager()
        fetchUserLocation()
    }
    
    private func setupLocationManager() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func bindActions() {
        
        localizeUserAction.subscribe(onNext: { [weak self] in
            self?.locationManager.requestLocation()
        })
        .disposed(by: disposeBag)
        
        locationManager.rx.didUpdateLocations
            .throttle(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe { [weak self] event in
                self?.locationManager.stopUpdatingLocation()
                self?.fetchWeatherData(for: event.element?.locations.first)
            }
            .disposed(by: disposeBag)
        
        locationManager.rx.didError
            .subscribe(onNext: { event in
                print("There was an error fetching user location: ",event.error)
            })
            .disposed(by: disposeBag)
    }
    
    // Fetch the weather forecasts in a property, the views must observe it to get forecast events.
    func fetchWeatherData(for location: CLLocation? = nil) {
        
        guard let unwrappedLocation = location else {
            print("Unable to fetch weather data, location is missing")
            return
        }

        isLoading.onNext(true)
        
        reverseGeocodeCity(for: unwrappedLocation)
        
        let urlString = getUrlString(from: unwrappedLocation)
        
        weatherService.fetchWeatherForecast(with: urlString)
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
    
    // MARK: - CoreLocation Methods
    
    // Use this method to observe the user location authorization status.
    private func fetchUserLocation() {
        
        locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { [weak self] event in
                switch event.status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.locationManager.requestLocation()
                case .notDetermined:
                    self?.locationManager.requestWhenInUseAuthorization()
                case .denied:
                    // TODO: - Present an alert to ask the user to go to the app settings and modify the authorization status.
                    print("Location authorization status denied")
                case .restricted:
                    print("Location authorization status restricted")
                @unknown default:
                    print("Unknown location authorization status")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func reverseGeocodeCity(for location: CLLocation) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first, let city = placemark.locality {
                self.currentCity
                    .onNext(city)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getUrlString(from location: CLLocation) -> String {
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let coordinateString: String = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,cloud_cover&hourly=temperature_2m&forecast_days=1"
        
        return coordinateString
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
        temperatureFormatter.roundingMode = .down
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
