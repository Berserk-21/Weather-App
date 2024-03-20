//
//  Coordinator.swift
//  Weather App
//
//  Created by Berserk on 13/03/2024.
//

import UIKit

protocol CoordinatorInterface {
    var coordinator: Coordinator? { get set }
}

final class Coordinator {
    
    var window: UIWindow
    var storyboard: UIStoryboard
    
    init(storyboard: UIStoryboard, window: UIWindow) {
        self.storyboard = storyboard
        self.window = window
    }
    
    func start() {
        
        // Force starting with onboarding.
        #if DEBUG
//        UserDefaults.standard.setValue(false, forKey: Constants.UserDefaults.didPresentOnboarding)
        #endif
        
        guard let vc = getViewController() else {
            fatalError("Could not instantiate a controller to start with")
        }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    // Use this method to instantiate the right controller as root view controller.
    private func getViewController() -> UIViewController? {
        
        if didPresentOnboarding() {
            guard let weatherNavigationController = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.WeatherNavigationController) as? UINavigationController else {
                fatalError("Could not instantiate a controller with id: \(Constants.StoryboardIdentifiers.WeatherNavigationController)")
            }
            
            guard let weatherViewController = weatherNavigationController.topViewController as? WeatherViewController else {
                fatalError("Could not instantiate a controller of type WeatherViewController")
            }
            
            weatherViewController.coordinator = self
            
            return weatherNavigationController
        } else {
            guard let onboardingVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.OnboardingViewController) as? OnboardingViewController else {
                fatalError("Could not instantiate a controller with id: \(Constants.StoryboardIdentifiers.OnboardingViewController)")
            }

            onboardingVC.coordinator = self

            return onboardingVC
        }
    }
    
    private func didPresentOnboarding() -> Bool {
                
        return UserDefaults.standard.bool(forKey: Constants.UserDefaults.didPresentOnboarding)
    }
    
    func didEndOnboarding() {
        
        UserDefaults.standard.setValue(true, forKey: Constants.UserDefaults.didPresentOnboarding)
        
        guard let weatherVC = getViewController() as? UINavigationController else {
            fatalError("Could not instantiate a WeatherViewController")
        }
        
        DispatchQueue.main.async {
            self.window.rootViewController = weatherVC
        }
    }
    
    func goToSettings() {
        
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
}
