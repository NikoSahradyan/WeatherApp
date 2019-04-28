//
//  InitialControllerViewModel.swift
//  FavouriteLocations
//
//  Created by Developer on 27/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class InitialControllerViewModel: NSObject, TableViewModelProtocol {
    var receivedResult = [SearchCellModel]() {
        didSet {
            isEmpty(receivedResult.isEmpty)
        }
    }
    var localStorageService = LocalStorageService.shared
    var reloadTable: (() -> Void)
    var enableEditButton: ((Bool) -> Void)
    var isEmpty: (Bool) -> Void//for showing hint view
    
    init(enableEditButton: @escaping ((Bool) -> Void),
         reloadTable: @escaping (() -> Void),
         isEmpty: @escaping (Bool) -> Void) {
        self.enableEditButton = enableEditButton
        self.reloadTable = reloadTable
        self.isEmpty = isEmpty
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
    //delete action in edit mode
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
    //pull to refresh case
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
    //recieveing data from local storage
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchCell,
            receivedResult.count > indexPath.row else {
                return UITableViewCell()
        }
        let cellModel = receivedResult[indexPath.row]
        
        return self.configCell(cell: cell, cellModel: cellModel)
    }
}


extension InitialControllerViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight()
    }
    //table view swipe to delete feature
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
    //table view edit mode move feature
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.receivedResult[sourceIndexPath.row]
        receivedResult.remove(at: sourceIndexPath.row)
        receivedResult.insert(movedObject, at: destinationIndexPath.row)
        localStorageService.rearrangeWithFollowingOrder(cellModels: receivedResult)
    }
}


