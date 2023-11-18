//
//  ViewController.swift
//  Lab8-SamMathew
//
//  Created by Sam Mathew on 2023-11-17.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityLabel: UILabel!  //Label displaying name of city
    
    @IBOutlet weak var descriptionLabel: UILabel! //Label displaying weather type
    
    @IBOutlet weak var weatherIconImageView: UIImageView! //Image displaying weather image
    
    @IBOutlet weak var temperatureLabel: UILabel! //Label displaying temperature
    
    @IBOutlet weak var humidityLabel: UILabel! //Label displaying humidity percentage
    
    @IBOutlet weak var windSpeedLabel: UILabel! //Label displaying wind speeds
    
    private var locationManager = CLLocationManager()
    private var weather: WeatherModel?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
        
    private func setupUI() { //Setup UI
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cityLabel, descriptionLabel, weatherIconImageView, temperatureLabel, humidityLabel, windSpeedLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    }
        
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
            WeatherService().getWeather(for: location) { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self.weather = WeatherModel(weatherResponse: weatherResponse)
                        self.updateUI()
                    }
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }
    }
        
    private func updateUI() {
        guard let weather = weather else { return }
            cityLabel.text = "\(weather.city)" //Display city name
            descriptionLabel.text = "\(weather.weatherDescription)" //Display weather type
        switch weather.weatherIcon { //using switch case to display appropriate image for weather
            case "01d":
                weatherIconImageView.image = UIImage(systemName: "sun.max.fill")
            case "01n":
                weatherIconImageView.image = UIImage(systemName: "moon.fill")
            case "02d", "02n":
                weatherIconImageView.image = UIImage(systemName: "cloud.sun.fill")
            case "03d", "03n":
                weatherIconImageView.image = UIImage(systemName: "cloud.fill")
            case "04d", "04n":
                weatherIconImageView.image = UIImage(systemName: "cloud")
            case "09d", "09n":
                weatherIconImageView.image = UIImage(systemName: "cloud.drizzle.fill")
            case "10d", "10n":
                weatherIconImageView.image = UIImage(systemName: "cloud.rain.fill")
            case "11d", "11n":
                weatherIconImageView.image = UIImage(systemName: "cloud.bolt.fill")
            case "13d", "13n":
                weatherIconImageView.image = UIImage(systemName: "cloud.snow.fill")
            case "50d", "50n":
                weatherIconImageView.image = UIImage(systemName: "cloud.fog.fill")
            default:
                weatherIconImageView.image = UIImage(systemName: "questionmark.diamond.fill")
        }
        temperatureLabel.text = "\(weather.temperature)°C" //Display temperature
        humidityLabel.text = "Humidity: \(weather.humidity)%" //Display humidity percentage
        windSpeedLabel.text = "Wind Speed: \(weather.windSpeed) m/s" //Display wind speed
    }
        
    private class WeatherService {  //calling API
    private let apiKey = "a14878a409042908db4c453c9c660ac5"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        
    func getWeather(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
            let urlString = "\(baseURL)?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=metric&appid=\(apiKey)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
                
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
        }
    }
        
    private struct WeatherResponse: Codable {
        let main: Main
        let weather: [Weather]
        let wind: Wind
    }
        
    private struct Main: Codable {
        let temp: Double
        let humidity: Int
    }
        
    private struct Weather: Codable {
        let description: String
        let icon: String
    }
    
    private struct Wind: Codable {
        let speed: Double
    }
        
    private struct WeatherModel {
        let city: String
        let weatherDescription: String
        let weatherIcon: String
        let temperature: Double
        let humidity: Int
        let windSpeed: Double
        
        init(weatherResponse: WeatherResponse) {
            self.city = "Waterloo"
            self.weatherDescription = weatherResponse.weather[0].description
            self.weatherIcon = weatherResponse.weather[0].icon
            self.temperature = weatherResponse.main.temp
            self.humidity = weatherResponse.main.humidity
            self.windSpeed = weatherResponse.wind.speed
        }
    }
}

