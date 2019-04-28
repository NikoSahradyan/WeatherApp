//
//  ViewController.swift
//  JooMagWeather
//
//  Created by Developer on 29/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

protocol TableViewModelProtocol {
    func cellHeight() -> CGFloat
    func configCell(cell: SearchCell, cellModel: SearchCellModel) -> SearchCell
}

extension TableViewModelProtocol {
    //different sizes of cells just for fun
    func cellHeight() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 100
        case .pad, .tv, .carPlay, .unspecified:
            return 150
        }
    }
    
    func configCell(cell: SearchCell, cellModel: SearchCellModel) -> SearchCell {
        if cellModel == SearchCellModel.empty {
            cell.locationNameLabel.text = cellModel.name
            cell.windInfoStack.isHidden = true
            cell.temperatureLabel.text = nil
            cell.conditionText.text = nil
            cell.weatherInfoStack.isHidden = true
        } else {
            cell.temperatureLabel.text = String(cellModel.temperature)
            cell.locationNameLabel.text = cellModel.name
            cell.icon.setImageFromUrl(imageUrl: URL(string: cellModel.conditionIcon ?? "")!)
            cell.windDirection.text = cellModel.windDirection
            cell.windSpeed.text = String(cellModel.windSpeed)
            cell.conditionText.text = cellModel.conditionText
        }
        return cell
    }
}
