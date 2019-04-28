//
//  LocationSearchService.swift
//  FavouriteLocations
//
//  Created by Developer on 26/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class LocationSearchService: NSObject {
    static var shared = LocationSearchService()
    
    func searchWithQuery(query: String, completionClosure: @escaping (SearchCellModel) -> Void) {
        let url = "http://api.apixu.com/v1" + "/current.json?" + "key=cfd41348829e47f0af1190214192604" + "&q=" + query
        guard let finalUrl = URL(string: url) else {
            return
        }
        let currentTask = URLSession.shared.dataTask(with: finalUrl) { (data, response, currentError) in
            if let recivedData = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with:
                    recivedData, options: []),
                    let parsableDict : [String: Any] = jsonResponse as? [String:Any] {
                    completionClosure(self.parse(response: parsableDict, query: query))
                }
            } else {
                completionClosure(SearchCellModel.empty)
            }
        }
        currentTask.resume()
    }
    
    func parse(response: [String:Any], query: String) -> SearchCellModel {
        guard response["error"] == nil else {
            return SearchCellModel.empty
        }
        var name: String?
        var temperature: Int16?
        var conditionIcon: String?
        var conditionText: String?
        var windSpeed: Int16?
        var windDirection: String?
        if let currentDict: Dictionary<String, Any> = response["current"] as? Dictionary<String, Any> {
            windSpeed = currentDict["wind_kph"] as? Int16
            windDirection = currentDict["wind_dir"] as? String
            temperature = currentDict["temp_c"] as? Int16
            if let currentCondition: Dictionary<String, Any> = currentDict["condition"] as? Dictionary<String, Any> {
                conditionText = currentCondition["text"] as? String
                conditionIcon = currentCondition["icon"] as? String
                conditionIcon = "http:" + (conditionIcon ?? "")
            }
        }
        if let locationDict: Dictionary<String, Any> = response["location"] as? Dictionary<String, Any> {
            name = locationDict["name"] as? String
        }
        return SearchCellModel(name: name, temperature: temperature, conditionIcon: conditionIcon, conditionText: conditionText, windSpeed: windSpeed, windDirection: windDirection, query: query)
    }

}
