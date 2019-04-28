//
//  ViewController.swift
//  JooMagWeather
//
//  Created by Developer on 28/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var emptyStateView: UIView!
    
    lazy var viewModel: InitialControllerViewModel = {
        var isEmpty: (Bool) -> Void = { [weak self] showEmpty in
            self?.emptyStateView.isHidden = !showEmpty
            self?.tableView.isHidden = showEmpty
        }
        var reloadTable = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        var enableEditButton: (Bool) -> Void = { [weak self] enable in
            self?.navigationItem.leftBarButtonItem?.isEnabled = enable
            if !enable {
                self?.shouldShowDeleteButton(hide: true)
            }
            
        }
        var model = InitialControllerViewModel(enableEditButton: enableEditButton, reloadTable: reloadTable, isEmpty: isEmpty)
        model.setupTableView(tableView: tableView)
        
        return model
    } ()
    
    var refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        _ = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: false)
        shouldShowDeleteButton(hide: true)
    }
    
    @IBAction func editAction(_ sender: Any) {
        viewModel.isEditMode = !viewModel.isEditMode
        shouldShowDeleteButton(hide: tableView.isEditing)
        tableView.setEditing(!tableView.isEditing, animated: false)
    }
    
    func shouldShowDeleteButton(hide: Bool) {
        if !hide && navigationItem.leftBarButtonItems?.count == 1 {
            let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target:self , action: #selector(deleteItems))
            navigationItem.leftBarButtonItems?.append(deleteButton)
        } else if hide && navigationItem.leftBarButtonItems?.count == 2 {
            navigationItem.leftBarButtonItems?.removeLast()
        }
    }
    
    @objc func deleteItems() {
        viewModel.deleteItems(tableView: tableView)
    }
    
    @objc func didPullToRefresh() {
        viewModel.updateAllItems { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func unwindToMainiewController(segue:UIStoryboardSegue) { }
    
    
}

