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
    var fetchResultController: NSFetchedResultsController<LocationInfo>
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "JooMagWeather")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        workingContext = persistentContainer.viewContext
        let request = NSFetchRequest<LocationInfo>(entityName: "LocationInfo")
        request.sortDescriptors = [NSSortDescriptor(key: "idx", ascending: false)]
        request.returnsObjectsAsFaults = false
        fetchResultController = NSFetchedResultsController<LocationInfo>(fetchRequest: request,
                                                                         managedObjectContext: workingContext,
                                                                         sectionNameKeyPath: nil,
                                                                         cacheName: nil)
        
        
        super.init()
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
    }
    
    func addNewFavouriteLocation(cellModel: SearchCellModel) {
        let currentNames = self.currentItems().map{ $0.name }
        //Skiping item if it is already in local storage
        guard !currentNames.contains(cellModel.name) else {
            return
        }
        
        let newModel = LocationInfo(context: workingContext)
        newModel.name = cellModel.name
        newModel.temperature = cellModel.temperature
        newModel.conditionText = cellModel.conditionText
        newModel.conditionIcon = cellModel.conditionIcon
        newModel.windSpeed = cellModel.windSpeed
        newModel.windDirection = cellModel.windDirection
        newModel.idx = Int16(currentItems().count)
        newModel.query = cellModel.query

        try? workingContext.save()
    }
    
    func removeFavouriteLocations(locations: [LocationInfo]) {
        var itemsAfterUpdate = currentItems()
        let sortedLocations = locations.sorted(by: { $0.idx > $1.idx })
        for location in sortedLocations {
            itemsAfterUpdate.remove(at: Int(location.idx - 1))
            workingContext.delete(location)
        }
        //after deleting swtting up right indexing
        for item in itemsAfterUpdate.enumerated() {
            item.element.setValue(itemsAfterUpdate.count - item.offset, forKey: "idx")
        }
        try? workingContext.save()
    }
    
    func removeFavouriteLocations(cellModels: [SearchCellModel]) {
        let locationList = cellModels.compactMap { $0.storedLocation }
        removeFavouriteLocations(locations: locationList)
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
    
    //for updating local storage in case of movements
    func rearrangeWithFollowingOrder(cellModels: [SearchCellModel]) {
        for cellModel in cellModels.enumerated() {
            let itemIndex = Int16(cellModels.count - cellModel.offset)
            cellModel.element.storedLocation?.setValue(itemIndex, forKey: "idx")
        }
        try? workingContext.save()
    }
    //for pull to refresh feature
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
        try? workingContext.save()
        
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
