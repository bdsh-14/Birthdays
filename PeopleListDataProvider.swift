//
//  PeopleListDataProvider.swift
//  Birthdays
//
//  Created by dasdom on 27.03.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import UIKit
import CoreData

public class PeopleListDataProvider: NSObject, PeopleListDataProviderProtocol {
  
  public var managedObjectContext: NSManagedObjectContext?
  weak public var tableView: UITableView!
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
  
    let dateFormatter: DateFormatter
  
  override public init() {
    dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    
    super.init()
  }
  
  public func addPerson(personInfo: PersonInfo) {
    let context = self.fetchedResultsController.managedObjectContext
    let entity = self.fetchedResultsController.fetchRequest.entity!
    let person = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context) as! Person
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    person.firstName = personInfo.firstName
    person.lastName = personInfo.lastName
    person.birthday = personInfo.birthday
    
    // Save the context.
    var error: NSError? = nil
    do {
        try context.save()
    } catch {
        abort()
    }
//    if !context.save(&error) {
//      // Replace this implementation with code to handle the error appropriately.
//      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//      print("Unresolved error \(error), \(error!.userInfo)")
//      abort()
//    }
  }
  
  func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
    let person = self.fetchedResultsController.object(at: indexPath) as! Person
    cell.textLabel!.text = person.fullname
    cell.detailTextLabel!.text = dateFormatter.string(from: person.birthday as Date)
  }
  
//  public func personForIndexPath(indexPath: NSIndexPath) -> Person? {
//    return fetchedResultsController.objectAtIndexPath(indexPath) as? Person
//  }
//  
  public func fetch() {
    let sortKey = UserDefaults.standard.integer(forKey: "sort") == 0 ? "lastName" : "firstName"
    
    let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
    let sortDescriptors = [sortDescriptor]
    
    fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
    var error: NSError? = nil
    
    do {
        try fetchedResultsController.performFetch()
    } catch {
        print(error.localizedDescription)
    }
    
//    if !fetchedResultsController.performFetch(&error) {
//      print("error: \(error)")
//    }
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension PeopleListDataProvider: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
           self.configureCell(cell: cell, atIndexPath: indexPath)
           return cell
    }
    
  
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController.sections?.count ?? 0
  }
  
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
    return sectionInfo.numberOfObjects
  }

  
  public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
        }
    }
  
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: IndexPath) {
    if editingStyle == .delete {
      let context = self.fetchedResultsController.managedObjectContext
        context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
      
      var error: NSError? = nil
        
        do {
            try context.save()
        } catch {
        abort()
        }
        
//      if !context.save(&error) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        //println("Unresolved error \(error), \(error.userInfo)")
//        abort()
//      }
    }
  }
  
}

// MARK: NSFetchedResultsControllerDelegate
extension PeopleListDataProvider: NSFetchedResultsControllerDelegate {
  
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
    // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: self.managedObjectContext!)
    fetchRequest.entity = entity
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
    let sortDescriptors = [sortDescriptor]
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
    var error: NSError? = nil
        
        do {
            try  _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
       
        
//    if !_fetchedResultsController!.performFetch(&error) {
//      // Replace this implementation with code to handle the error appropriately.
//      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//      //println("Unresolved error \(error), \(error.userInfo)")
//      abort()
//    }
    
    return _fetchedResultsController!
  }
  
    public func controllerWillChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
  }
  
    public func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
        self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
    case .delete:
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
    default:
      return
    }
  }
  
    public func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .insert:
        tableView.insertRows(at: [newIndexPath!] as [IndexPath], with: .fade)
    case .delete:
        tableView.deleteRows(at: [indexPath!] as [IndexPath], with: .fade)
    case .update:
        self.configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)!, atIndexPath: indexPath! as IndexPath)
    case .move:
        tableView.deleteRows(at: [indexPath!] as [IndexPath], with: .fade)
        tableView.insertRows(at: [newIndexPath!] as [IndexPath], with: .fade)
    default:
      return
    }
  }
  
    public func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
  }

}
