//
//  MyEventsViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 6/8/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventCategorySegmentedControl: UISegmentedControl!
    
    // Manual cell row height
    let tableViewCellRowHeight: CGFloat = 76
    
    // List of displayable events
    var myEvents: [Event] = []
    
    // Copy of initial list of displayable events
    var myEventsHardCopy: [Event] = []
    
    // List of user hosted events to display
    var myHostedEvents: [Event] = []
    
    // List of user hosted joined to display
    var myJoinedEvents: [Event] = []
    
    // Event object holding currently selected event
    var selectedEvent = Event()
    
    // Flag specifying if filter option cell is opened
    var filterOptionsOpened = false
    
    // Number of filters (number of rows in a table view)
    var filterOptionCount = 1
    
    // Current filter
    var currentFilter = ""
    
    // Specifies which events to display
    var currentEventCategory = "All"
    
    // Custom segmented control height
    let kSegmentedControlHeight: CGFloat = 41
    
    override func viewDidLayoutSubviews() {
        self.eventCategorySegmentedControl.frame = CGRect(x: eventCategorySegmentedControl.frame.origin.x, y: eventCategorySegmentedControl.frame.origin.y, width: eventCategorySegmentedControl.frame.width, height: kSegmentedControlHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventCategorySegmentedControl.frame = CGRect(x: eventCategorySegmentedControl.frame.origin.x, y: eventCategorySegmentedControl.frame.origin.y, width: eventCategorySegmentedControl.frame.width, height: kSegmentedControlHeight)
        
        // Fetch user events from the server
        EventDataManager.shared.RetrieveEventsBasedOnFilter(view: self, eventSearchFilter: .owner, filter: LoginManager.username) { events in
            self.myHostedEvents = events
        }
        
        EventDataManager.shared.RetrieveEventsBasedOnFilter(view: self, eventSearchFilter: .participantName, filter: LoginManager.username) { events in
            self.myJoinedEvents = events
            
            self.myEvents           = self.myHostedEvents + self.myJoinedEvents
            self.myEventsHardCopy   = self.myEvents
            self.tableView.reloadData()
        }
    }
    
    @IBAction func EventCategory_SegmentChanged(_ sender: UISegmentedControl) {
        let category = sender.titleForSegment(at: sender.selectedSegmentIndex)
        self.currentEventCategory = category ?? "All"
        
        if category == "All" {
            myEvents = myEventsHardCopy
        } else if category == "Hosting" {
            myEvents = myHostedEvents
        } else if category == "Joined" {
            myEvents = myJoinedEvents
        }
        
        // Apply the filter to events from a new category
        if !currentFilter.isEmpty {
            var filteredEvents: [Event] = []
            
            // Loop through all currently displayable events and pick out the ones that match the specified filter
            for event in myEvents {
                if event.title.contains(currentFilter) {
                    filteredEvents.append(event)
                }
            }
            
            myEvents = filteredEvents
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // update global copy of the filter
        self.currentFilter = searchBar.text ?? ""
        
        // If no filter is set, set current event list to the initial unchanged copy of all events
        if searchBar.text!.isEmpty {
            myEvents = myEventsHardCopy
            tableView.reloadData()
            return
        }
        
        // reset myEvents based on the current category
        if currentEventCategory == "All" {
            myEvents = myEventsHardCopy
        } else if currentEventCategory == "Hosting" {
            myEvents = myHostedEvents
        } else if currentEventCategory == "Joined" {
            myEvents = myJoinedEvents
        }
        
        var filteredEvents: [Event] = []
        
        // Loop through all currently displayable events and pick out the ones that match the specified filter
        for event in myEventsHardCopy {
            if event.title.contains(searchBar.text!) {
                filteredEvents.append(event)
            }
        }
        
        myEvents = filteredEvents
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // If it's the second row and above and unless it's a filter cell, return custom row height, otherwise return default which is 44
        if indexPath.row > 0 {
            if indexPath.row == 1 && filterOptionsOpened {
                return 44.0
            } else {
                return tableViewCellRowHeight
            }
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The extra "1" integer constant represents the first cell which is used for toggling filter rows
        if filterOptionsOpened {
            return myEvents.count + 1 + filterOptionCount
        }
        return myEvents.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "filterTitleCell")!
        cell.textLabel?.text = "Filter"
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .none
        
        if indexPath.row > 0 {
            if indexPath.row < (filterOptionCount + 1) {
                if filterOptionsOpened {
                    // If filter options are opened, dequeue filter cells
                    cell = tableView.dequeueReusableCell(withIdentifier: "filterCell")!
                    let searchBar = (cell as! FilterCell).searchBar
                    searchBar?.showsCancelButton = true
                    searchBar?.delegate = self
                } else {
                    // If filter options are closed, dequeue normal event cells
                    cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")!
                    (cell as! EventCell).eventTitle.text = myEvents[indexPath.row - 1].title
                    (cell as! EventCell).eventImage.image = UIImage(named: "eventsIcon")
                    
                    // set event icon to blue icon if the user is participating in that event
                    if myEvents[indexPath.row - 1].owner != LoginManager.username {
                        (cell as! EventCell).eventImage.image = UIImage(named: "blueEventsIcon")
                    }
                }
            }
            else if indexPath.row >= (filterOptionCount + 1) {
                cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")!
                var offset = 1
                if filterOptionsOpened {
                    // If filter options are opened, change the offset depending on number of filter options
                    offset = 1 + filterOptionCount
                }
                (cell as! EventCell).eventTitle.text = myEvents[indexPath.row - offset].title
                (cell as! EventCell).eventImage.image = UIImage(named: "eventsIcon")
                
                // set event icon to blue icon if the user is participating in that event
                if myEvents[indexPath.row - offset].owner != LoginManager.username {
                    (cell as! EventCell).eventImage.image = UIImage(named: "blueEventsIcon")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If the first row (toggles filter row) is selected
        if indexPath.row == 0 {
            // Toggle filter options
            if filterOptionsOpened {
                // Delete the row containing filter option
                filterOptionsOpened = false
                tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            } else {
                // Insert the row containing filter option
                filterOptionsOpened = true
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            }
        } else {
            // Perform the segue to EventViewerViewController and view the selected event
            if filterOptionsOpened {
                if indexPath.row >= (filterOptionCount + 1) {
                    selectedEvent = myEvents[indexPath.row - 1 - filterOptionCount]
                    performSegue(withIdentifier: Segues.ViewEvent, sender: nil)
                }
            } else {
                selectedEvent = myEvents[indexPath.row - 1]
                performSegue(withIdentifier: Segues.ViewEvent, sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewEventSegue" {
            let vc = segue.destination as! EventViewerViewController
            
            // Pass the copy of the event object
            vc.event = selectedEvent
            
            // Pass the preserved viewing mode state
            if selectedEvent.owner != LoginManager.username {
                vc.viewingMode = .View
            } else {
                vc.viewingMode = .Edit
            }
            
            // Pass the preserved current identifier for the exit segue
            vc.exitSegueIdentifier = "returnToMyEventsSegue"
        }
    }
}

class EventCell : UITableViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class FilterCell : UITableViewCell {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
