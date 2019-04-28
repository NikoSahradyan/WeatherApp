//
//  LocalStorageService.swift
//  FavouriteLocations
//
//  Created by Developer on 28/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit
import CoreData

protocol LocalStorageServiceDelegate {
    func favouriteLocationsDidUpdate(newLocations: [LocationInfo])
}

class LocalStorageService: NSObject {
    
    static var shared = LocalStorageService()
    
    var delegateList = [LocalStorageServiceDelegate]()
    var persistentContainer: NSPersistentContainer
    var workingContext: NSManagedObjectContext
    var privateManagedObjectContext: NSManagedObjectContext
    var fetchResultController: NSFetchedResultsController<LocationInfo>
    
    
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "JooMagWeather")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        workingContext = persistentContainer.viewContext
        
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        privateManagedObjectContext .persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        let request = NSFetchRequest<LocationInfo>(entityName: "LocationInfo")
        request.sortDescriptors = [NSSortDescriptor(key: "idx", ascending: false)]
        request.returnsObjectsAsFaults = false
        fetchResultController = NSFetchedResultsController<LocationInfo>(fetchRequest: request,
                                                                         managedObjectContext: privateManagedObjectContext,
                                                                         sectionNameKeyPath: nil,
                                                                         cacheName: nil)
        
        
        super.init()
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
    }
    
    func addNewFavouriteLocation(cellModel: SearchCellModel) {
        let newModel = LocationInfo(context: privateManagedObjectContext)
        newModel.name = cellModel.name
        newModel.temperature = cellModel.temperature
        newModel.conditionText = cellModel.conditionText
        newModel.conditionIcon = cellModel.conditionIcon
        newModel.windSpeed = cellModel.windSpeed
        newModel.windDirection = cellModel.windDirection
        newModel.idx = Int16(currentItems().count)
        newModel.query = cellModel.query

        try? privateManagedObjectContext.save()
    }
    
    func removeFavouriteLocations(locations: [LocationInfo]) {
        for location in locations {
            privateManagedObjectContext.delete(location)
        }
        try? privateManagedObjectContext.save()
    }
    
    func removeFavouriteLocations(cellModels: [SearchCellModel]) {
        for currentModel in cellModels {
            if let strongLocation = currentModel.storedLocation {
                privateManagedObjectContext.delete(strongLocation)
            }
        }
        try? privateManagedObjectContext.save()
    }
    
    func rearrangeWithFollowingOrder(cellModels: [SearchCellModel]) {
        for cellModel in cellModels.enumerated() {
            cellModel.element.storedLocation?.setValue(Int16(cellModels.count - 1 - cellModel.offset), forKey: "idx")
        }
        try? privateManagedObjectContext.save()
    }
    
    func currentItems() -> [LocationInfo] {
        guard let currentLocations = fetchResultController.fetchedObjects else {
            return [LocationInfo]()
        }
        
        return currentLocations
    }
    
    func currentItemModels() -> [SearchCellModel] {
        let items = self.currentItems()
        var modelList = [SearchCellModel]()
        for item in items {
            modelList.append(SearchCellModel(location: item))
        }
        return modelList
    }
    
    func updateWeatherInfo(newModels: [SearchCellModel]) {
        let oldItems = currentItems()
        let namesForIdentifing = newModels.map { $0.name }
        for oldItem in oldItems {
            if let name = oldItem.name,
                let newIndex = namesForIdentifing.firstIndex(of: name) {
                let newItem = newModels[newIndex]
                oldItem.setValue(newItem.temperature, forKey: "temperature")
                oldItem.setValue(newItem.conditionIcon, forKey: "conditionIcon")
                oldItem.setValue(newItem.conditionText, forKey: "conditionText")
                oldItem.setValue(newItem.windSpeed, forKey: "windSpeed")
                oldItem.setValue(newItem.windDirection, forKey: "windDirection")
            }
        }
        try? privateManagedObjectContext.save()
        
    }

}


extension LocalStorageService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let currentResult = fetchResultController.fetchedObjects ?? [LocationInfo]()
        for listener in delegateList {
            listener.favouriteLocationsDidUpdate(newLocations: currentResult)
        }
    }
}
