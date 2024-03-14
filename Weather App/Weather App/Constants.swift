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
            static let settingsButtonTitle = "Settings"
            static let networkErrorMessage = "Please check your internet connection and retry !"
            static let loadingLabelText = "Fetching weather.."
            static let settingsLabelText = "Go to Privacy -> Locations Services -> Weather App"
        }
        
        enum OnboardingView {
            static let localWeatherLabelText = "We need your authorization to fetch the weather of your current city !"
            static let notDeterminedTitle = "Fetch my city !"
            static let deniedTitle = "Settings"
            static let restrictedTitle = "GPS unavailable"
            static let restrictedSettingsText = "There is a problem with the GPS of your device !"
        }
    }
    
    enum Geolocation {
        enum Error {
            static let locationUnknown = "location is currently unknown"
            static let denied = "Please allow our app to locate you !"
            static let network = "Geolocation network error"
            static let defaultMessage = "Unable to get a location, please check your privacy settings"
            static let title = "Location unavailable"
            static let restricted = "Location authorization status restricted"
        }
    }
    
    enum FetchingWeather {
        enum Error {
            static let didFail = "Fetching weather failed"
            static let defaultMessage = "Something was wrong preparing the weather data"
        }
    }
    
    enum UserDefaults {
        static let didPresentOnboarding = "didPresentOnboarding"
    }
    
    enum SegueIdentifiers {
        static let fromHomeToOnboarding = "fromHomeToOnboarding"
    }
    
    enum StoryboardIdentifiers {
        static let OnboardingViewController = "OnboardingViewController"
        static let WeatherViewController = "WeatherViewController"
        static let WeatherNavigationController = "WeatherNavigationController"
    }
}
