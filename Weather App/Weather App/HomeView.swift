//
//  HomeView.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import UIKit
import RxSwift

final class HomeView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherCodeLabel: UILabel!
    @IBOutlet private weak var maxMinTemperatureLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var filterView: UIView!
    
    // MARK: - Life Cycle
    
    required init?(coder: NSCoder) {
        viewModel = WeatherViewModel()
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        
        subscribe()
        
        viewModel.fetchWeatherData()
    }
    
    private func setupUI() {
        cityLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        temperatureLabel.font = UIFont.systemFont(ofSize: 80.0, weight: .light)
        weatherCodeLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        maxMinTemperatureLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        filterView.alpha = 0.2
    }
    
    // MARK: - Binding Methods
    
    private func subscribe() {
            
        viewModel.weatherForecast
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] forecast in
                self?.setupCurrentWeather(with: forecast)
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("did complete forecast")
            }
            .disposed(by: disposeBag)
    }
    
    private func setupCurrentWeather(with forecast: WeatherForecastModel) {
        
        cityLabel.text = "Montpellier"
        temperatureLabel.text = "\(forecast.current.temperature_2m)°"
        weatherCodeLabel.text = descriptionForWeatherCode(forecast.current.weather_code)
        maxMinTemperatureLabel.text = describeExtremeTemperatures(with: forecast)
        backgroundImageView.image = getBackgroundImageForWeatherCode(forecast.current.weather_code)
    }
    
    // MARK: - Helper Methods
    
    func describeExtremeTemperatures(with forecast: WeatherForecastModel) -> String {
        
        var string = ""
        
        if let maxTemp = forecast.hourly.maxTemperature?.rounded(.down) {
            string += "↑\(maxTemp.rounded())°"
        }
        
        if let minTemp = forecast.hourly.minTemperature?.rounded(.down) {
            if !string.isEmpty {
                string += " "
            }
            
            string += "↓\(minTemp)°"
        }
        
        return string
    }
    
    func getBackgroundImageForWeatherCode(_ code: Int) -> UIImage? {
        
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
    
    func descriptionForWeatherCode(_ code: Int) -> String {
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

