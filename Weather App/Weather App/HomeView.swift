//
//  HomeView.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import UIKit
import RxSwift

final class HomeView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherCodeLabel: UILabel!
    @IBOutlet private weak var maxMinTemperatureLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var alertTexts: PublishSubject<(String, String)> = PublishSubject()
    
    // MARK: - Life Cycle
    
    required init?(coder: NSCoder) {
        viewModel = WeatherViewModel()
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
        setupBindings()
    }
    
    // MARK: - Setup Layout
    
    private func setupLayout() {
        
        cityLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        temperatureLabel.font = UIFont.systemFont(ofSize: 120.0, weight: .thin)
        weatherCodeLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        maxMinTemperatureLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        filterView.alpha = 0.2
        retryButton.setTitle(Constants.Views.HomeView.retryButtonTitle, for: .normal)
        retryButton.isHidden = true
    }
    
    // MARK: - Binding Methods
    
    private func setupBindings() {
        
        viewModel.currentTemperature?
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.minMaxTemperature?
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(to: maxMinTemperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.weatherCodeString?
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(to: weatherCodeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.backgroundImage?
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(to: backgroundImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.cityString?
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(to: cityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showError()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isLoading in
                if isLoading {
                    self?.hideErrorLayout(true)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.weatherForecast
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.hideErrorLayout(true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Coordination Methods
    
    private func showError() {
        
        // TODO: - Add a enum and a switch to present different errors.
        
        presentAlert(title: Constants.Views.HomeView.networkErrorTitle, message: Constants.Views.HomeView.networkErrorMessage)
        hideErrorLayout(false)
    }
    
    private func hideErrorLayout(_ hide:Bool) {
        
        retryButton.isHidden = hide
    }
    
    private func presentAlert(title: String, message: String) {
        
        alertTexts
            .onNext((title, message))
    }
    
    // MARK: - Actions
    
    @IBAction func didTapRetryButton(_ sender: Any) {
        
        viewModel.fetchWeatherData()
    }
    
}

