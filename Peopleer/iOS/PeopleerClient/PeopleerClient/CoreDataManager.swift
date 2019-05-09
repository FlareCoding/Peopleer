//
//  CoreDataUtils.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/8/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager
{
    static let shared = CoreDataManager()
    private var context: NSManagedObjectContext!
    
    init() {
        RefreshContext()
    }
    
    private func RefreshContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    func GetEntity(entityName: String) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    func SaveContext() -> Bool {
        do {
            try context.save()
        } catch {
            return false
        }
        return true
    }
    
    func deleteAllData(_ entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Delete all data in \(entity) error :", error)
        }
    }
}
