//
//  SearchCellModel.swift
//  FavouriteLocations
//
//  Created by Developer on 26/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

struct SearchCellModel {
    static var empty = SearchCellModel(name: "Sorry nothing was found", temperature: nil, conditionIcon: nil, conditionText: nil, windSpeed: nil, windDirection: nil, query: nil)
    public var name: String?
    public var temperature: Int16
    public var conditionIcon: String?
    public var conditionText: String?
    public var windSpeed: Int16
    public var windDirection: String?
    public var query: String?
    public var storedLocation: LocationInfo?
}

extension SearchCellModel {
    init(name: String?,
         temperature: Int16?,
         conditionIcon: String?,
         conditionText: String?,
         windSpeed: Int16?,
         windDirection: String?,
         query: String?) {
        self.init(name: name,
                  temperature: temperature ?? 0,
                  conditionIcon: conditionIcon,
                  conditionText: conditionText,
                  windSpeed: windSpeed ?? 0,
                  windDirection: windDirection,
                  query: query,
                  storedLocation: nil)
    }
    
    init(location: LocationInfo) {
        self.init(name: location.name,
                  temperature: location.temperature,
                  conditionIcon: location.conditionIcon,
                  conditionText: location.conditionText,
                  windSpeed: location.windSpeed,
                  windDirection: location.windDirection,
                  query: location.query,
                  storedLocation: location)
    }
}

extension SearchCellModel: Equatable {
    public static func == (lhs: SearchCellModel, rhs: SearchCellModel) -> Bool {
        return lhs.name == rhs.name
    }
}
