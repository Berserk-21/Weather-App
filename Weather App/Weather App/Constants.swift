//
//  Constants.swift
//  Weather App
//
//  Created by Berserk on 08/03/2024.
//

import Foundation

enum Constants {
    enum Views {
        enum HomeView {
            static let retryButtonTitle = "Retry"
            static let networkErrorMessage = "Please check your internet connection and retry !"
            static let loadingLabelText = "Fetching weather.."
        }
    }
    
    enum Geolocation {
        enum Error {
            static let locationUnknown = "location is currently unknown"
            static let denied = "Please check your privacy settings:\nSettings -> Privacy -> Locations Services -> Weather App"
            static let network = "Geolocation network error"
            static let defaultMessage = "Unable to get a location, please check your privacy settings"
            static let title = "Location unavailable"
            static let restricted = "Location authorization status restricted"
        }
    }
    
    enum FetchingWeather {
        enum Error {
            static let didFail = "Fetching weather failed"
        }
    }
}
