//
//  ViewController.swift
//  WeatherClima
//
//  Created by Oko-osi Korede on 30/01/2024.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    
    let locationManager = CLLocationManager()
    
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchTF.delegate = self
        weatherManager.delegate = self
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        performSearch()
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func performSearch() {
        guard let cityName = searchTF.text else { return }
        weatherManager.fetchWeather(cityName: cityName)
        searchTF.endEditing(true)
        
    }

}

//MARK: - UITextField Delegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSearch()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let tfText = textField.text, tfText != "" else {
            
            return false
        }
        return true
    }
}

//MARK: - Weather Manager Delegate
extension WeatherViewController: WeatherManagerDelegate {
    func didFailed(with error: Error) {
        print("Failed with error: \(error.localizedDescription)")
    }
    
    func didFetchWeatherDataComplete(_ weatherData: WeatherModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            conditionImageView.image = UIImage(systemName: weatherData.iconName)
            tempLabel.text = weatherData.temp
            cityLabel.text = weatherData.cityName
        }
    }
}

//MARK: - CoreLocation Delegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else {
            return
        }
        locationManager.stopUpdatingLocation()
        let lat = Float(userLocation.coordinate.latitude)
        let lon = Float(userLocation.coordinate.longitude)
        
        weatherManager.fetchWeather(lat: lat, lon: lon)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("An error occured: \(error.localizedDescription)")
    }
}
