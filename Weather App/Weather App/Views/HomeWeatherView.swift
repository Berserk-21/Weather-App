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
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var loadingLabel: UILabel!
    
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
        
        retryButton.setTitle(Constants.Views.HomeView.retryButtonTitle, for: .normal)
        retryButton.isHidden = true
        
        loadingLabel.text = Constants.Views.HomeView.loadingLabelText
        loadingLabel.textColor = .white
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
            retryButton.isHidden = true
            loadingLabel.isHidden = false
            contentView.isHidden = true
        case .error(let title, let message):
            activityIndicator.stopAnimating()
            filterView.alpha = 0.8
            retryButton.isHidden = false
            loadingLabel.isHidden = true
            contentView.isHidden = true
            presentAlert(title: title, message: message)
        case .completed:
            activityIndicator.stopAnimating()
            filterView.alpha = 0.2
            retryButton.isHidden = true
            loadingLabel.isHidden = true
            contentView.isHidden = false
        }
    }
    
    private func presentAlert(title: String, message: String) {
        
        alertTexts
            .onNext((title, message))
    }
    
    // MARK: - Actions
    
    @IBAction func didTapRetryButton(_ sender: Any) {
        
        viewModel.didTapRetryButton()
    }
    
}

