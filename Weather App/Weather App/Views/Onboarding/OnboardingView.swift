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
    @IBOutlet private weak var authorizeButton: UIButton!
        
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
        binding()
    }
    
    private func binding() {
        
        authorizeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.requestGeolocationAuthorization()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Setup Layout
    
    private func setupLayout() {
        
        backgroundImageView.image = UIImage(named: "earth")
        
        localWeatherLabel.text = Constants.Views.OnboardingView.localizeWeatherText
        localWeatherLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        localWeatherLabel.textColor = .white
        localWeatherLabel.textAlignment = .center
        
        authorizeButton.setTitle(Constants.Views.OnboardingView.authorizeButtonTitle, for: .normal)
    }
    
}

