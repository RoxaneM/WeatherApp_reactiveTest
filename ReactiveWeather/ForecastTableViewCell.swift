//
//  ForecastTableViewCell.swift
//  ReactiveWeather
//
//  Created by sdk on 8/28/17.
//  Copyright © 2017 Indeema. All rights reserved.
//

import UIKit

let ForecastTableViewCellIdentifier = "ForecastTableViewCellIdentifier"

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var temperatureValueLabel: UILabel!
    @IBOutlet weak var windSpeedValueLabel: UILabel!
    @IBOutlet weak var humidityValueLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with weather: Weather) {
        self.setDate(weather.timeStamp)
        self.temperatureValueLabel.text = String(weather.temperature) + "°C"
        self.windSpeedValueLabel.text = String(weather.windSpeed) + " mph"
        self.humidityValueLabel.text = String(weather.humidity) + "%"
        
        self.weatherIconImageView.kf.setImage(with: URL(string: weather.icon))
    }
    
    private func setDate(_ timeStamp: TimeInterval) {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd-MM-yyyy  hh:mm"
        
        let dateText = formatter.string(from: Date(timeIntervalSince1970: timeStamp))
        dateValueLabel.text = dateText
    }

}
