//
//  OnboardingViewModel.swift
//  Weather App
//
//  Created by Berserk on 14/03/2024.
//

import Foundation
import RxSwift
import RxCoreLocation
import CoreLocation

final class OnboardingViewModel {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private var disposeBag = DisposeBag()
    
    var didEndOnboarding = PublishSubject<Void>()
    
    // MARK: - Life Cycle
    
    init() {
        setupLocationManager()
        setupBindinds()
    }
    
    // MARK: - Setup Location Manager
    
    private func setupLocationManager() {
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Setup Bindings

    private func setupBindinds() {
        
        guard locationManager.authorizationStatus == .notDetermined else {
            fatalError("The authorization status is already determined. Do not forget to handle this case with a go to settings button")
        }
        
        locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { [weak self] event in
                switch event.status {
                case .notDetermined:
                    print("geolocation is notDetermined")
                case .denied:
                    print("geolocation is denied")
                case .restricted:
                    print("geolocation is restricted")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("geolocation is authorized")
                    self?.didEndOnboarding.onNext(())
                @unknown default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Core Location Methods
    
    func requestGeolocationAuthorization() {
        
        locationManager.requestWhenInUseAuthorization()
    }
}
