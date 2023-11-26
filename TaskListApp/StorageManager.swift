//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Елизавета Шалдыбина on 26.11.2023.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    let context: NSManagedObjectContext
    
    // MARK: - Core Data stack
    
    private var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func fetchData(completion: ([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let task = try context.fetch(fetchRequest)
            completion(task)
        } catch {
            print("Faild to fetch data", error)
        }
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func saveTask(_ title: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = title
        completion(task)
        saveContext()
    }
    
    func update(_ task: Task) {
        context.refresh(task, mergeChanges: true)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
