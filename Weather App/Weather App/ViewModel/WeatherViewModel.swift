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

enum FetchingState {
    case loading
    case error(ErrorState)
    case completed(WeatherDataModel)
}

enum ErrorState {
    case network(title: String, message: String)
    case geolocalization(title: String, message: String)
    case dataModeling(title: String, message: String)
}

final class WeatherViewModel {
    
    // MARK: - Properties
    
    private let weatherService: OpenWeatherService
    private let locationManager = CLLocationManager()
    private let temperatureFormatter = NumberFormatter()

    private var disposeBag = DisposeBag()
    
    private var weatherForecast: PublishSubject<OpenWeatherModel> = PublishSubject()
    private var currentCity: PublishSubject<String> = PublishSubject()
    
    // For some reason we can't trust the CoreLocation requestLocation method to fetch only one location.
    private var didRequestGeolocalization: Bool = false
    
    lazy var observableWeatherData: Observable<WeatherDataModel?> = {
        return Observable.zip(weatherForecast, currentCity)
            .map { [weak self] weatherData in
                
                guard let data = self?.getWeatherData(from: weatherData) else {
                    self?.fetchingState.onNext(.error(ErrorState.dataModeling(title: Constants.FetchingWeather.Error.didFail, message: Constants.FetchingWeather.Error.defaultMessage)))
                    return nil
                }

                self?.fetchingState.onNext(.completed(data))
                
                return nil
            }
            .asObservable()
    }()
    
    let fetchingState = PublishSubject<FetchingState>()
    let localizeUserAction = PublishSubject<Void>()
    
    init() {
        weatherService = OpenWeatherService()
        
        bindActions()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func bindActions() {
        
        localizeUserAction
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
            
            guard let didRequestGeolocalization = self?.didRequestGeolocalization, didRequestGeolocalization == false else { return }
            
            self?.fetchingState.onNext(.loading)
            self?.didRequestGeolocalization = true
            self?.locationManager.requestLocation()
        })
        .disposed(by: disposeBag)
        
        locationManager.rx.didUpdateLocations
            .throttle(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe { [weak self] event in
                
                guard let didRequestGeolocalization = self?.didRequestGeolocalization, didRequestGeolocalization == true else { return }
                
                self?.locationManager.stopUpdatingLocation()
                if let location = event.element?.locations.first {
                    self?.fetchWeatherData(for: location)
                } else {
                    self?.fetchingState.onNext(.error(ErrorState.geolocalization(title: Constants.FetchingWeather.Error.didFail, message: Constants.Geolocation.Error.locationUnknown)))
                }
                
                self?.didRequestGeolocalization = false
            }
            .disposed(by: disposeBag)
        
        locationManager.rx.didError
            .subscribe(onNext: { [weak self] event in
                if let clError = event.error as? CLError {
                    self?.didFailFetchingLocation(clError)
                } else {
                    fatalError("the error must be of type CLError")
                }
                self?.didRequestGeolocalization = false
            })
            .disposed(by: disposeBag)
    }
    
    // Fetch the weather forecasts in a property, the views must observe it to get forecast events.
    func fetchWeatherData(for location: CLLocation) {
        
        reverseGeocodeCity(for: location)
        
        let urlString = getUrlString(from: location)
        
        weatherService.fetchWeatherForecast(with: urlString)
            .subscribe { [weak self] forecast in
                self?.weatherForecast.onNext(forecast)
            } onError: { [weak self] error in
                self?.didFailFetchingWeather(with: error)
            } onCompleted: {
                // The completion we observe is the weatherData zip.
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - CoreLocation Methods
    
    // Use this method to observe the user location authorization status.
    func fetchUserLocation() {
        
        fetchingState.onNext(.loading)
        
        locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { [weak self] event in
                switch event.status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.didRequestGeolocalization = true
                    self?.locationManager.requestLocation()
                case .notDetermined:
                    self?.locationManager.requestWhenInUseAuthorization()
                case .denied:
                    self?.fetchingState.onNext(.error(ErrorState.geolocalization(title: Constants.Geolocation.Error.title, message: Constants.Views.HomeView.settingsLabelText)))
                case .restricted:
                    self?.fetchingState.onNext(.error(ErrorState.geolocalization(title: Constants.Geolocation.Error.title, message: Constants.Geolocation.Error.restricted)))
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
    
    private func didFailFetchingWeather(with error: Error) {
        
        let errorMessage: String

        if let weatherServiceError = error as? OpenWeatherServiceError {
            switch weatherServiceError {
            case .dataUnavailable:
                errorMessage = "Data unavailable"
                print("There was an error fetching Weather data: dataUnavailable")
            case .responseUnavailable:
                errorMessage = "Response unavailable"
                print("There was an error fetching Weather data: responseUnavailable")
            case .serverSideError(let statusCode):
                errorMessage = statusCode.description
                print("There was an error fetching Weather data: \(statusCode.description)")
            case .transportError(let error):
                errorMessage = error.localizedDescription
                print("There was an error fetching Weather data: \(error.localizedDescription)")
            }
        } else if let rxError = error as? RxError {
            switch rxError {
            case .timeout:
                errorMessage = Constants.FetchingWeather.Error.timeout
            default:
                errorMessage = Constants.FetchingWeather.Error.defaultMessage
            }
        } else {
            errorMessage = Constants.FetchingWeather.Error.defaultMessage
        }
        
        fetchingState.onNext(.error(ErrorState.network(title: Constants.FetchingWeather.Error.didFail, message: errorMessage)))
    }
    
    // MARK: - Helper Methods
    
    private func didFailFetchingLocation(_ error: CLError) {
        
        let errorMessage: String
        
        switch error.code {
        case .locationUnknown:
            errorMessage = Constants.Geolocation.Error.locationUnknown
        case .denied:
            errorMessage = Constants.Views.HomeView.settingsLabelText
        case .network:
            errorMessage = Constants.Geolocation.Error.network
        default:
            errorMessage = Constants.Geolocation.Error.defaultMessage
        }
        
        fetchingState.onNext(.error(ErrorState.geolocalization(title: Constants.Geolocation.Error.title, message: errorMessage)))
    }
    
    private func getWeatherData(from weatherData: (OpenWeatherModel, String)) -> WeatherDataModel? {
        
        guard let currentTemperature = formatTemperature(weatherData.0.current.temperature_2m) else { return nil }
        guard let backgroundImage = getBackgroundImageForWeatherCode(weatherData.0.current.weather_code) else { return nil }

        let minMaxTemperature = formatExtremeTemperatures(from: weatherData.0)
        let weatherCode = descriptionForWeatherCode(weatherData.0.current.weather_code)
        
        return WeatherDataModel(city: weatherData.1, currentTemperature: currentTemperature, minMaxTemperature: minMaxTemperature, weatherCode: weatherCode, backgroundImage: backgroundImage)
    }
    
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
            return UIImage(named: "earth")
        }
    }
    
    private func formatTemperature(_ temperature: CGFloat) -> String? {
        temperatureFormatter.roundingMode = .down
        temperatureFormatter.maximumFractionDigits = 0
        
        return temperatureFormatter.string(from: NSNumber(floatLiteral: temperature))
    }
    
    private func formatExtremeTemperatures(from forecast: OpenWeatherModel) -> String {
        
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
