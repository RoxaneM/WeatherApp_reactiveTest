//
//  ForecastViewController.swift
//  ReactiveWeather
//
//  Created by sdk on 8/28/17.
//  Copyright © 2017 Indeema. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ForecastViewController: UIViewController {
    static let maxAttempts = 4
    
    @IBOutlet weak var forecastTableView: UITableView!
    
    var city: String?
    
    let disposeBag = DisposeBag()
  
    
//MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        loadForecastData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
//MARK: Rx observables setup
    
    private func loadForecastData() {
        if city != nil {
            let list = WeatherHelper.shared.currentWeather(city: city!)
                .retryWhen(retryHandler)
            .share()
            
                list.subscribe(onNext: { forecastsTuple in
                    print(forecastsTuple)
                },
                           onError: {error in
                            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                                DispatchQueue.main.async {
                                    self.title = "No Internet connection."
                                }
                            }
                })
                .disposed(by: self.disposeBag)
            
            //populate tableView
            list.map { $0.0 }
                .bind(to: self.forecastTableView.rx.items) {
                    (tableView: UITableView, index: Int, forecastItem: Weather) in
                    let cell: ForecastTableViewCell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCellIdentifier, for: IndexPath(row: index, section: 0)) as! ForecastTableViewCell

                    cell.update(with: forecastItem)
                    return cell
                }
                .disposed(by: disposeBag)
            
            //update title
            list.map { $0.1 ?? "" }
                .bind(to: self.rx.title)
            .disposed(by: disposeBag)
        }
    }
    
    private let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
        return e.flatMapWithIndex { (error, attempt) -> Observable<Int> in
            
            if attempt >= maxAttempts - 1 {
                return Observable.error(error)
            }
            
            if let castError = error as? WeatherHelper.WeatherHelperError, castError == .invalidJSON || castError == .cityNotFound{
                return Observable.error(error)
            }
            //TODO: debug only
            //print("== retrying after \(attempt + 1) seconds ==")
            
            return Observable<Int>.timer(Double(attempt + 1), scheduler: MainScheduler.instance).take(1)
        }
    }
}
