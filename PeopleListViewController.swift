//
//  PeopleListViewController.swift
//  Birthdays
//
//  Created by dasdom on 27.03.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import UIKit
import CoreData
import AddressBookUI

public class PeopleListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  public var dataProvider: PeopleListDataProviderProtocol?
    public var userDefaults = UserDefaults.standard
  public var communicator: APICommunicatorProtocol = APICommunicator()

  override public func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
    self.navigationItem.rightBarButtonItem = addButton
    
//    assert(dataProvider != nil, "dataProvider is not allowed to be nil at this point")
    tableView.dataSource = dataProvider
    dataProvider?.tableView = tableView
  }
  
  @objc func addPerson() {
    let picker = ABPeoplePickerNavigationController()
    picker.peoplePickerDelegate = self
    present(picker, animated: true, completion: nil)
  }

  public func fetchPeopleFromAPI() {
    let allPersonInfos = communicator.getPeople().1
    if let allPersonInfos = allPersonInfos {
      for personInfo in allPersonInfos {
        dataProvider?.addPerson(personInfo: personInfo)
      }
    }
  }
  
  public func sendPersonToAPI(personInfo: PersonInfo) {
    communicator.postPerson(personInfo: personInfo)
  }
  
  @IBAction func changeSorting(sender: UISegmentedControl) {
    userDefaults.set(sender.selectedSegmentIndex, forKey: "sort")
    dataProvider?.fetch()
  }
  
}

extension PeopleListViewController: ABPeoplePickerNavigationControllerDelegate {
  
  public func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
    let personInfo = PersonInfo(abRecord: person)
    dataProvider?.addPerson(personInfo: personInfo)
  }
  
}

