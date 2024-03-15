//
//  OnboardingView.swift
//  Weather App
//
//  Created by Berserk on 14/03/2024.
//

import UIKit
import RxSwift

final class OnboardingView: UIView {
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    
    let viewModel = OnboardingViewModel()
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var localWeatherLabel: UILabel!
    @IBOutlet weak var authorizeButton: UIButton!
    @IBOutlet private weak var settingsLabel: UILabel!
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
        binding()
        setupInitialState()
    }
    
    private func setupInitialState() {
        
        viewModel.determineInitialState()
    }
    
    private func binding() {
        
        viewModel.locationState
            .subscribe(onNext: { [weak self] state in
                self?.updateLayout(for: state)
            })
            .disposed(by: disposeBag)
        
        authorizeButton.rx.tap
            .withLatestFrom(viewModel.locationState)
            .subscribe { [weak self] event in
                if let state = event.element {
                    switch state {
                    case .notDetermined:
                        self?.viewModel.requestGeolocationAuthorization()
                    case .denied:
                        self?.viewModel.didTapOpenSettings.onNext(())
                    default:
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Setup Layout
    
    private func setupLayout() {
        backgroundImageView.image = UIImage(named: "earth")
        
        localWeatherLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        localWeatherLabel.textColor = .white
        localWeatherLabel.textAlignment = .center
    }
    
    private func updateLayout(for state: LocationAuthorizationState) {
        
        let buttonTitle: String
        var settingsText: String = ""
        
        localWeatherLabel.text = Constants.Views.OnboardingView.localWeatherLabelText
        
        switch state {
        case .notDetermined:
            buttonTitle = Constants.Views.OnboardingView.notDeterminedTitle
        case .denied:
            buttonTitle = Constants.Views.OnboardingView.deniedTitle
            settingsText = Constants.Views.HomeView.settingsLabelText
        case .restricted:
            buttonTitle = Constants.Views.OnboardingView.restrictedTitle
            settingsText = Constants.Views.OnboardingView.restrictedSettingsText
        }
        
        localWeatherLabel.text = Constants.Views.OnboardingView.localWeatherLabelText
        authorizeButton.setTitle(buttonTitle, for: .normal)
        settingsLabel.text = settingsText
    }
    
}

