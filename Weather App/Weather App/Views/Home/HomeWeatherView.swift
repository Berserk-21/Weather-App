//
//  HomeWeatherView.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import UIKit
import RxSwift

final class HomeWeatherView: UIView {
    
    // MARK: - Properties
    
    let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var temperatureDegreeLabel: UILabel!
    @IBOutlet private weak var weatherCodeLabel: UILabel!
    @IBOutlet private weak var maxMinTemperatureLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var settingsLabel: UILabel!
    @IBOutlet private weak var settingsVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var loadingLabel: UILabel!
    
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
    }
    
    // MARK: - Binding Methods
    
    private func setupWeatherDataBindings() {
        
        viewModel.observableWeatherData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weatherData in
                self?.presentWeatherData(weatherData)
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
            activityIndicator.startAnimating()
            filterView.alpha = 0.8
            settingsVisualEffectView.isHidden = true
            loadingLabel.isHidden = false
            contentView.isHidden = true
        case .error(let title, let message):
            activityIndicator.stopAnimating()
            filterView.alpha = 0.8
            settingsVisualEffectView.isHidden = false
            loadingLabel.isHidden = true
            contentView.isHidden = true
            presentAlert(title: title, message: message)
        case .completed:
            activityIndicator.stopAnimating()
            loadingLabel.isHidden = true
            contentView.isHidden = false
            settingsVisualEffectView.isHidden = true
        }
    }
    
    private func presentAlert(title: String, message: String) {
        
        alertTexts
            .onNext((title, message))
    }
    
    private func presentWeatherData(_ weatherData: WeatherDataModel, animate: Bool = true) {
        
        if animate {
            UIView.animate(withDuration: 0.8) {
                self.temperatureLabel.text = weatherData.currentTemperature
                self.maxMinTemperatureLabel.text = weatherData.minMaxTemperature
                self.cityLabel.text = weatherData.city
                self.weatherCodeLabel.text = weatherData.weatherCode
                self.backgroundImageView.image = weatherData.backgroundImage
                self.filterView.alpha = 0.2
            }
        } else {
            temperatureLabel.text = weatherData.currentTemperature
            maxMinTemperatureLabel.text = weatherData.minMaxTemperature
            cityLabel.text = weatherData.city
            weatherCodeLabel.text = weatherData.weatherCode
            backgroundImageView.image = weatherData.backgroundImage
            filterView.alpha = 0.2
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapRetryButton(_ sender: Any) {
        
        goToSettings
            .onNext(true)
    }
    
}

