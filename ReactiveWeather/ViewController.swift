//
//  ViewController.swift
//  ReactiveWeather
//
//  Created by sdk on 8/27/17.
//  Copyright © 2017 Indeema. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    var citiesList = Variable<[String]>([])
    
    let disposeBag = DisposeBag()
    

//MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchTextChangedObserving()
        setupSearchResultsObserving()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
  
//MARK: Rx observables setup
    
    private func setupSearchTextChangedObserving() {
        //only search for words that contain more than two letters
        let searchInput = citySearchBar.rx.value
            .filter {
                let numberOfLetters = ($0 ?? "").characters.count
                if numberOfLetters < 3 {
                    self.citiesList.value = []
                    return false
                }
                return true
        }
        
        let searchResults = searchInput.flatMap { inputText in
            return GeoHelper.shared.searchCities(text: inputText ?? "Error")
        }
        
        searchResults.bind(to: citiesList)
            .disposed(by: disposeBag)
        
        citySearchBar.rx.searchButtonClicked.subscribe {_ in
            self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
  
    private func setupSearchResultsObserving() {
        citiesList.asObservable().bind(to: searchResultTableView.rx.items) {
            (tableView: UITableView, index: Int, element: String) in
            let cell = UITableViewCell(style: .default, reuseIdentifier: CityTableViewCellIdentifier)
            cell.textLabel?.text = element
            return cell }
            .disposed(by: disposeBag)
        
        searchResultTableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { city in
                
                let forecastViewController = self.storyboard!.instantiateViewController(withIdentifier: "ForecastViewController") as! ForecastViewController
                forecastViewController.city = city
                self.navigationController!.pushViewController(forecastViewController, animated: true)
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

