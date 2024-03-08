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

class WeatherViewController: UIViewController {

    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bindAlert()
    }
    
    private func bindAlert() {
        
        if let homeView = view as? HomeView {
            homeView.alertTexts
                .subscribe(onNext: { [weak self] (title, message) in
                    self?.presentAlertWith(title: title, message: message)
                })
                .disposed(by: disposeBag)
            
        }
    }
    
    private func presentAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
}

