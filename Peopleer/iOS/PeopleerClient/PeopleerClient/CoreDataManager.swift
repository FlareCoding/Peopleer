//
//  CoreDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/27/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private var appDelegate: AppDelegate
    private var context: NSManagedObjectContext
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func updateContext() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func insertData(entity: String, attribs: [String : Any]) -> Bool {
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: entity, into: context)
        for pair in attribs {
            newEntity.setValue(pair.value, forKey: pair.key)
        }
        
        do {
            try context.save()
            return true
        }
        catch {
            return false
        }
    }
    
    func retrieveObjects(entity: String) -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results as? [NSManagedObject]
            }
            else {
                return nil
            }
        }
        catch {
            return nil
        }
    }
    
    func getObject<T: Equatable>(managedObjectPool: [NSManagedObject], keyName: String, value: T) -> NSManagedObject? {
        for object in managedObjectPool {
            let result = object.value(forKey: keyName) as? T
            if result != nil {
                if result == value {
                    return object
                }
            }
        }
        return nil
    }
    
    func saveContext() -> Bool {
        do {
            try context.save()
            return true
        } catch { return false }
    }
    
}

