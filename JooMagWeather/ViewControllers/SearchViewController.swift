//
//  SearchViewController.swift
//  JooMagWeather
//
//  Created by Developer on 28/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchFiled: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    @IBAction func cancelSearch(_ sender: Any) {
        viewModel.closeSearch()
    }
    
    lazy var viewModel: SearchViewModel = {
        var reloadTable = { [weak self] in
            DispatchQueue.main.async {
                self?.searchResultTableView.reloadData()
            }
        }
        var closeSearch: () -> Void = { [weak self] in
            self?.performSegue(withIdentifier: "unwindToMain", sender: self)
        }
        var model = SearchViewModel(reloadTable: reloadTable, closeSearch: closeSearch)
        model.setupTextField(textFiled: searchFiled)
        model.setupTableView(tableView: searchResultTableView)
        
        return model
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.searchFiled.becomeFirstResponder()
        _ = viewModel
    }
    
}
