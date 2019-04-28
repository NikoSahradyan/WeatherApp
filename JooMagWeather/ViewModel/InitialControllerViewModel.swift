//
//  InitialControllerViewModel.swift
//  FavouriteLocations
//
//  Created by Developer on 27/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit
import CoreData

protocol TableViewModel {
    func cellHeight() -> CGFloat
    func configCell(cell: SearchCell, cellModel: SearchCellModel) -> SearchCell
}

extension TableViewModel {

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
        } else {
            cell.temperatureLabel.text = String(cellModel.temperature)
            cell.locationNameLabel.text = cellModel.name
            cell.icon.setImageFromUrl(imageUrl: URL(string: cellModel.conditionIcon ?? "")!)
            cell.windDirection.text = cellModel.windDirection
            cell.windSpeed.text = String(cellModel.windSpeed)
        }
        return cell
    }
}

class InitialControllerViewModel: NSObject, TableViewModel {
    var receivedResult = [SearchCellModel]() {
        didSet {
            isEmpty(receivedResult.isEmpty)
        }
    }
    var localStorageService = LocalStorageService.shared
    var reloadTable: (() -> Void)
    var enableEditButton: ((Bool) -> Void)
    var isEmpty: (Bool) -> Void
    var needToUpdateLocalStorage = false
    var isEditMode: Bool {
        didSet {
            
        }
    }
    
    init(enableEditButton: @escaping ((Bool) -> Void),
         reloadTable: @escaping (() -> Void),
         isEmpty: @escaping (Bool) -> Void) {
        self.enableEditButton = enableEditButton
        self.reloadTable = reloadTable
        self.isEmpty = isEmpty
        self.isEditMode = false
        super.init()
        localStorageService.delegateList.append(self)
        self.receivedResult = localStorageService.currentItemModels()
        enableEditButton(!self.receivedResult.isEmpty)
        isEmpty(self.receivedResult.isEmpty)
    }
    
    
    
    func setupTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    
    func deleteItems(tableView: UITableView) {
        guard let selectedRows = tableView.indexPathsForSelectedRows?.map({ $0.row }) else{
            return
        }
        let elementsToDelete = receivedResult.enumerated()
            .filter { selectedRows.contains($0.offset) }
            .map { $0.element }
        localStorageService.removeFavouriteLocations(cellModels: elementsToDelete)
        for element in elementsToDelete {
            if let idx = receivedResult.firstIndex(of: element) {
                receivedResult.remove(at: idx)
            }
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: tableView.indexPathsForSelectedRows!, with: .none)
        tableView.endUpdates()
    }
    
    func updateAllItems(completionBlock: @escaping () -> Void) {
        var locationsToUpdate = receivedResult.count
        var updatedLocations = [SearchCellModel]()
        for location in receivedResult {
            if let query = location.query {
                LocationSearchService.shared.searchWithQuery(query: query) { cellModel in
                    updatedLocations.append(cellModel)
                    locationsToUpdate -= 1
                    if locationsToUpdate == 0 {
                        self.localStorageService.updateWeatherInfo(newModels: updatedLocations)
                        completionBlock()
                    }
                }
            }
            
        }
    }
    
}

extension InitialControllerViewModel: LocalStorageServiceDelegate {
    func favouriteLocationsDidUpdate(newLocations: [LocationInfo]) {
        receivedResult = [SearchCellModel]()
        for location in newLocations {
            receivedResult.append(SearchCellModel(location: location))
        }
        enableEditButton(receivedResult.count != 0)
        reloadTable()
    }
}

extension InitialControllerViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedResult.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchCell,
            receivedResult.count > indexPath.row else {
                return UITableViewCell()
        }
        let cellModel = receivedResult[indexPath.row]
        cell.temperatureLabel.text = String(cellModel.temperature)
        cell.locationNameLabel.text = cellModel.name
        cell.icon.setImageFromUrl(imageUrl: URL(string: cellModel.conditionIcon ?? "")!)
        cell.windDirection.text = cellModel.windDirection
        cell.windSpeed.text = String(cellModel.windSpeed)
        
        return cell
    }
}


extension InitialControllerViewModel: UITableViewDelegate {
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            guard let deletingObject = self?.receivedResult[indexPath.row] else {
                return
            }
            self?.receivedResult.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self?.localStorageService.removeFavouriteLocations(cellModels: [deletingObject])
        }

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        needToUpdateLocalStorage = true
        let movedObject = self.receivedResult[sourceIndexPath.row]
        receivedResult.remove(at: sourceIndexPath.row)
        receivedResult.insert(movedObject, at: destinationIndexPath.row)
        localStorageService.rearrangeWithFollowingOrder(cellModels: receivedResult)
    }
}


