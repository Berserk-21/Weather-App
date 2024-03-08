//
//  OpenWeatherService.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import Foundation
import RxSwift

final class OpenWeatherService {
    
    /// Use this method to fetch weather data from Open Weather API.
    func fetchWeatherForecast() -> Observable<WeatherForecastModel> {
    
        // Get the current and hourly weather of the day.
        let currentWeatherUrlString = "https://api.open-meteo.com/v1/forecast?latitude=43.6109&longitude=3.8763&current=temperature_2m,weather_code,cloud_cover&hourly=temperature_2m&forecast_days=1"
        
        guard let url = URL(string: currentWeatherUrlString) else { return Observable.error(NSError(domain: "", code: -1))}
        
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let unwrappedData = data else {
                    return observer.onError(NSError(domain: "no data", code: -2))
                }
                
                // Uncomment for reading json received in a string format.
//                if let string = String(data: unwrappedData, encoding: .utf8) {
//                    print("string: ",string)
//                }
                
                do {
                    let forecast = try JSONDecoder().decode(WeatherForecastModel.self, from: unwrappedData)
                    observer.onNext(forecast)
                } catch let err {
                    observer.onError(err)
                }
                
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
