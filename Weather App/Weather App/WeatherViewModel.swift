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
    
    
    init() {
        weatherService = OpenWeatherService()
    }
    
    // Fetch weather forecast in a property, the views must observe it to get forecast events.
    func fetchWeatherData() {
        
        weatherService.fetchWeatherForecast()
            .subscribe { [weak self] forecast in
                self?.weatherForecast.onNext(forecast)
            } onError: { error in
                print("error: \(error)")
            } onCompleted: {
                print("did fetch weather data")
            }
            .disposed(by: disposeBag)
    }
    
}
