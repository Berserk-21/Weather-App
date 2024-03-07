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
    
    // MARK: - Life Cycle
    
    required init?(coder: NSCoder) {
        viewModel = WeatherViewModel()
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout()
        
        setupBindings()
        
        viewModel.fetchWeatherData()
    }
    
    // MARK: - Setup Layout
    
    private func setupLayout() {
        
        cityLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        temperatureLabel.font = UIFont.systemFont(ofSize: 120.0, weight: .thin)
        weatherCodeLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        maxMinTemperatureLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        filterView.alpha = 0.2
    }
    
    // MARK: - Binding Methods
    
    private func setupBindings() {
        
        viewModel.currentTemperature?
            .compactMap { $0 }
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.minMaxTemperature?
            .compactMap { $0 }
            .bind(to: maxMinTemperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.weatherCodeString?
            .compactMap { $0 }
            .bind(to: weatherCodeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.backgroundImage?
            .compactMap { $0 }
            .bind(to: backgroundImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.cityString?
            .compactMap { $0 }
            .bind(to: cityLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}

