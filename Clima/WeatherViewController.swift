//
//  ViewController.swift
//  WeatherApp
//
//  Created by David Lee on 11/25/17.
//  Copyright © 2017 David Lee. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "b77870a9e6ccbebde0fbbb8e9e2f24b1" //API Key 
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self //setting weatherviewcontroller as delegate of locationManager
        // setup delegate so that locationManager knows to report location data to weatherviewController
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //set accuracy location to within hundred meters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //LM starts looking for GPS locations of device asynchronously to WVController, works in background on seperate thread while main thread with app is working
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    
    func getWeatherData(url: String, params: [String: String]) {
        Alamofire.request(url, method: .get, parameters: params).responseJSON { (response) in
            if response.result.isSuccess {
                print("Success! Got the weather data!")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   

    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double {
            let tempConvertedToF = round((Double(tempResult) * (9/5)) - 459.67)
            weatherDataModel.temp = Int(tempConvertedToF)//convert temp value that is provided in kelvin units to fahrenheit
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    func updateUIWithWeatherData() {
        self.cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temp)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 { //stop location as soon as valid location found
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil //removes class from receiving weather data after receiving data once
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, params: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        let params: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, params: params)
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


