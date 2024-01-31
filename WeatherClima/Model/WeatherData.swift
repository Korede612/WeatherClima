//
//  WeatherData.swift
//  WeatherClima
//
//  Created by Oko-osi Korede on 30/01/2024.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: MainWeather
}

struct Weather: Codable {
    let id: Int
}

struct MainWeather: Codable {
    let temp: Float
    
}
