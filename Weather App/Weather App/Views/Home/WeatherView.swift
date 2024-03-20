//
//  WeatherView.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import UIKit
import RxSwift

final class WeatherView: UIView {
    
    // MARK: - Properties
    
    let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var errorContentView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var temperatureDegreeLabel: UILabel!
    @IBOutlet private weak var weatherCodeLabel: UILabel!
    @IBOutlet private weak var maxMinTemperatureLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var initialBackgroundImageView: UIImageView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var settingsLabel: UILabel!
    @IBOutlet private weak var settingsVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var loadingLabel: UILabel!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var alertTexts: PublishSubject<(String, String)> = PublishSubject()
    var goToSettings: PublishSubject<Bool> = PublishSubject()
    
    // MARK: - Life Cycle
    
    required init?(coder: NSCoder) {
        viewModel = WeatherViewModel()
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
        setupWeatherDataBindings()
        viewModel.fetchUserLocation()
    }
    
    // MARK: - Setup Layout
    
    private func setupLayout() {
        
        activityIndicator.style = .large
        activityIndicator.color = .white
        
        cityLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        cityLabel.textColor = .white
        
        temperatureLabel.font = UIFont.systemFont(ofSize: 120.0, weight: .thin)
        temperatureLabel.textColor = .white
        
        temperatureDegreeLabel.font = temperatureLabel.font
        temperatureDegreeLabel.textColor = .white
        
        weatherCodeLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        weatherCodeLabel.textColor = .white
        
        maxMinTemperatureLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        maxMinTemperatureLabel.textColor = .white
        
        filterView.alpha = 0.2
        
        settingsVisualEffectView.isHidden = true
        settingsButton.setTitle(Constants.Views.HomeView.settingsButtonTitle, for: .normal)
        
        settingsLabel.text = Constants.Views.HomeView.settingsLabelText
        settingsLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        settingsLabel.textColor = .white
        
        loadingLabel.text = Constants.Views.HomeView.loadingLabelText
        loadingLabel.textColor = .white
        
        errorLabel.text = Constants.Geolocation.Error.title
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        
        initialBackgroundImageView.image = UIImage(named: "earth")
    }
    
    // MARK: - Binding Methods
    
    private func setupWeatherDataBindings() {
        
        viewModel.observableWeatherData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weatherData in
//                self?.presentWeatherData(weatherData)
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchingState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.updateFetchingStateLayout(for: state)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Coordination Methods
    
    private func updateFetchingStateLayout(for state: FetchingState) {
        
        switch state {
        case .loading:
            presentLoadingLayout()
           
        case .error(let state):
            
            presentErrorLayout(for: state)
            
        case .completed(let data):
            presentWeather(from: data)
        }
    }
    
    private func presentLoadingLayout() {
        
        filterView.alpha = 0.8
        
        errorContentView.alpha = 1.0
        backgroundImageView.alpha = 0.0
        
        errorContentView.isHidden = false
        initialBackgroundImageView.isHidden = false
        backgroundImageView.isHidden = true

        contentView.isHidden = true
        settingsVisualEffectView.isHidden = true

        activityIndicator.startAnimating()

        loadingLabel.isHidden = false
        errorLabel.isHidden = true
    }
    
    private func presentErrorLayout(for state: ErrorState) {
        
        filterView.alpha = 0.8
        backgroundImageView.alpha = 0.0

        errorContentView.isHidden = false
        settingsVisualEffectView.isHidden = false
        backgroundImageView.isHidden = true
        
        contentView.isHidden = true
        
        activityIndicator.stopAnimating()
        
        loadingLabel.isHidden = true
        errorLabel.isHidden = false
        
        let alertTitle: String
        let alertMessage: String
        
        switch state {
        case .dataModeling(let title, let message):
            alertTitle = title
            alertMessage = message
            
            errorLabel.text = message
            
            settingsVisualEffectView.isHidden = true
            
        case.geolocalization(let title, let message):
            alertTitle = title
            alertMessage = message
            
            errorLabel.text = title
            settingsLabel.text = message
            
        case .network(let title, let message):
            alertTitle = title
            alertMessage = message

            errorLabel.text = title
            
            settingsVisualEffectView.isHidden = true
        }
        
        presentAlert(title: alertTitle, message: alertMessage)
    }
    
    private func presentWeather(from data: WeatherDataModel, animate: Bool = true) {
        
        temperatureLabel.text = data.currentTemperature
        maxMinTemperatureLabel.text = data.minMaxTemperature
        cityLabel.text = data.city
        weatherCodeLabel.text = data.weatherCode
        backgroundImageView.image = data.backgroundImage
        
        contentView.isHidden = false
        contentView.alpha = 0.0
        errorContentView.isHidden = true
        backgroundImageView.isHidden = false
        
        activityIndicator.stopAnimating()
        
        layoutIfNeeded()
        
        if animate {
            
            UIView.animate(withDuration: 0.8) {

                self.filterView.alpha = 0.2
                self.backgroundImageView.alpha = 1.0
                self.errorContentView.alpha = 0.0
                self.contentView.alpha = 1.0
                                
                self.layoutIfNeeded()
            }
        } else {
            filterView.alpha = 0.2
            backgroundImageView.alpha = 1.0
            contentView.alpha = 1.0
            errorContentView.alpha = 0.0
        }
    }
    
    private func presentAlert(title: String, message: String) {
        
        alertTexts
            .onNext((title, message))
    }
    
    // MARK: - Actions
    
    @IBAction func didTapRetryButton(_ sender: Any) {
        
        goToSettings
            .onNext(true)
    }
    
}

