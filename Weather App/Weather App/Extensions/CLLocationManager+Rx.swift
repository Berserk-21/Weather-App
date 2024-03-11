//
//  CLLocationManager+Rx.swift
//  Weather App
//
//  Created by Berserk on 08/03/2024.
//

import CoreLocation
import RxSwift
import RxCocoa

// TODO: - Compare to the RxColeLocation framework later.

//extension CLLocationManager: HasDelegate {
//    public typealias Delegate = CLLocationManagerDelegate
//}

//public class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
//    
//    weak public private(set) var locationManager: CLLocationManager?
//
//    public init(locationManager: CLLocationManager) {
//        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
//    }
//
//    public static func registerKnownImplementations() {
//        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
//    }
//
//    internal lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
//    internal lazy var didFailWithErrorSubject = PublishSubject<Error>()
//
//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        _forwardToDelegate?.locationManager?(manager, didUpdateLocations: locations)
//        didUpdateLocationsSubject.onNext(locations)
//    }
//
//    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        _forwardToDelegate?.locationManager?(manager, didFailWithError: error)
//        didFailWithErrorSubject.onNext(error)
//    }
//    
//    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        _forwardToDelegate?.locationManagerDidChangeAuthorization(manager)
//    }
//
//    deinit {
//        self.didUpdateLocationsSubject.on(.completed)
//        self.didFailWithErrorSubject.on(.completed)
//    }
//}

//public extension Reactive where Base: CLLocationManager {
//    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
//        RxCLLocationManagerDelegateProxy.proxy(for: base)
//    }
//    
//    var locations: Observable<[CLLocation]> {
//        let proxy = RxCLLocationManagerDelegateProxy.proxy(for: base)
//        return proxy.didUpdateLocationsSubject.asObservable()
//    }
//    
//    var didChangeAuthorization: ControlEvent<CLAutho
//}
