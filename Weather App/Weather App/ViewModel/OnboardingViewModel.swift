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

enum LocationAuthorizationState {
    case denied
    case restricted
    case notDetermined
}

final class OnboardingViewModel {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private var disposeBag = DisposeBag()
    
    var didTapOpenSettings = PublishSubject<Void>()
    var didEndOnboarding = PublishSubject<Void>()
    var locationState = PublishSubject<LocationAuthorizationState>()
    
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
        
        locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { [weak self] event in
                switch event.status {
                case .notDetermined:
                    print("geolocation is notDetermined")
                case .denied:
                    self?.locationState.onNext(.denied)
                case .restricted:
                    print("geolocation is restricted")
                    self?.locationState.onNext(.restricted)
                case .authorizedAlways, .authorizedWhenInUse:
                    print("geolocation is authorized")
                    self?.didEndOnboarding.onNext(())
                @unknown default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func determineInitialState() {
                
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationState.onNext(.notDetermined)
        case .authorizedAlways, .authorizedWhenInUse:
            didEndOnboarding.onNext(())
        case .denied:
            locationState.onNext(.denied)
        case .restricted:
            locationState.onNext(.restricted)
        default:
            break
        }
    }
    
    // MARK: - Core Location Methods
    
    func requestGeolocationAuthorization() {
        
        locationManager.requestWhenInUseAuthorization()
    }
}
