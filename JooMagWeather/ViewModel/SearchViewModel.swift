//
//  SearchViewModel.swift
//  FavouriteLocations
//
//  Created by Developer on 26/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit
import CoreData

class SearchViewModel: NSObject, TableViewModel {
    var receivedResult = [SearchCellModel]()
    var reloadTable: () -> Void
    var closeSearch: () -> Void
    var currentQuery: String?
    
    
    init(reloadTable: @escaping () -> Void, closeSearch: @escaping () -> Void) {
        self.reloadTable = reloadTable
        self.closeSearch = closeSearch
        super.init()
    }
    
    func searchWithQuery(query: String?) {
        guard let searchText = query else {
            receivedResult = [SearchCellModel.empty]
            self.reloadTable()
            return
        }
        currentQuery = searchText
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 1) {
            if self.currentQuery == searchText {
                LocationSearchService.shared.searchWithQuery(query: searchText) { cellModel in
                    self.receivedResult = [cellModel]
                    self.reloadTable()
                }
            }
        }
    }
    
    func setupTextField(textFiled: UITextField) {
        textFiled.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchWithQuery(query: textField.text)
    }
}

extension SearchViewModel: UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight()
    }
}


extension SearchViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard receivedResult.count > indexPath.row,
            receivedResult[indexPath.row] != SearchCellModel.empty else {
            return
        }
        LocalStorageService.shared.addNewFavouriteLocation(cellModel: receivedResult[indexPath.row])
        
        closeSearch()
    }
}
