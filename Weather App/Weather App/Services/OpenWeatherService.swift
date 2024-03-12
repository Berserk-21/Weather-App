//
//  OpenWeatherService.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import Foundation
import RxSwift

enum OpenWeatherServiceError: Error {
    case transportError(Error)
    case responseUnavailable
    case dataUnavailable
    case serverSideError(Int)
}

final class OpenWeatherService {
    
    /// Use this method to fetch weather data from Open Weather API.
    func fetchWeatherForecast(with urlString: String) -> Observable<WeatherForecastModel> {
    
        guard let url = URL(string: urlString) else { return Observable.error(NSError(domain: "", code: -1))}
        
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(OpenWeatherServiceError.transportError(error))
                    return
                }
                
                guard let unwrappedResponse = response as? HTTPURLResponse else {
                    return observer.onError(OpenWeatherServiceError.responseUnavailable)
                }
                
                guard let unwrappedData = data else {
                    return observer.onError(OpenWeatherServiceError.dataUnavailable)
                }
                
                // Uncomment to read the json received in a string format.
//                if let string = String(data: unwrappedData, encoding: .utf8) {
//                    print("string: ",string)
//                }
                
                guard (200...299).contains(unwrappedResponse.statusCode) else {
                    return observer.onError(OpenWeatherServiceError.serverSideError(unwrappedResponse.statusCode))
                }
                
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
