//
//  WeatherViewController.swift
//  Weather App
//
//  Created by Berserk on 05/03/2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

final class WeatherViewController: UIViewController, CoordinatorInterface {

    private var disposeBag = DisposeBag()
    private var viewModel: WeatherViewModel!
    var coordinator: Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bindings()
        setupBarButton()
    }
    
    private func bindings() {
        
        if let homeView = view as? HomeWeatherView {
            self.viewModel = homeView.viewModel
            
            homeView.alertTexts
                .subscribe(onNext: { [weak self] (title, message) in
                    self?.presentAlertWith(title: title, message: message)
                })
                .disposed(by: disposeBag)
            
            homeView.goToSettings
                .subscribe(onNext: { [weak self] _ in
                    self?.goToSettings()
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func setupBarButton() {
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "refresh"), style: .done, target: nil, action: nil)
        rightBarButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarButton
        
        rightBarButton.rx.tap
            .bind(to: viewModel.localizeUserAction)
            .disposed(by: disposeBag)
    }
    
    private func presentAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    private func goToSettings() {
        
        coordinator?.goToSettings()
    }
    
}

