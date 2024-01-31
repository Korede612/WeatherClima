//
//  WeatherManager.swift
//  WeatherClima
//
//  Created by Oko-osi Korede on 30/01/2024.
//

import Foundation

protocol WeatherManagerDelegate: AnyObject {
    func didFetchWeatherDataComplete(_ weatherData: WeatherModel)
    func didFailed(with error: Error)
}

enum WeatherError: Error {
    case badRequest
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=9250e45e424e1ca6a05fe8f347df00aa&units=metric"
    weak var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(lat: Float, lon: Float) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create a URL
        guard let url = URL(string: urlString) else { return }
        
        // 2. Create a URLSession
        let session = URLSession(configuration: .default)
        
        // 3. Give the session a task
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                delegate?.didFailed(with: error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                delegate?.didFailed(with: WeatherError.badRequest)
                return
            }
            
            guard let data
            else { return }
            parseData(from: data)
            
        }
        
        // 4. Start the task
        task.resume()
    }
    
    func parseData(from data: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            delegate?.didFetchWeatherDataComplete(weather)
        }
        catch {
            delegate?.didFailed(with: error)
        }
    }
}
