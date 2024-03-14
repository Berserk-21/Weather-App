//
//  OnboardingViewController.swift
//  Weather App
//
//  Created by Berserk on 13/03/2024.
//

import UIKit
import RxSwift

class OnboardingViewController: UIViewController, CoordinatorInterface {
    
    var coordinator: Coordinator?
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBindings()
    }
    
    private func setupNavigationBindings() {
        
        if let onboardingView = view as? OnboardingView {
            onboardingView.viewModel.didEndOnboarding
                .subscribe(onNext: { [weak self] _ in
                    self?.coordinator?.didEndOnboarding()
                })
                .disposed(by: disposeBag)
        }
    }
        
}
