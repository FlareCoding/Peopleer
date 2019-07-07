//
//  EventEditorViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 6/1/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class EventEditorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Button that either saves or updates the event
    @IBOutlet weak var saveNavigationBarButton: UIBarButtonItem!
    
    // Preserved copy of viewing mode from EventViewerViewController that specifies event viewing rights (Create, Edit, or View)
    var viewingMode = EventViewerViewControllerViewingMode.Edit
    
    // Event object to hold current event data
    var event = Event()
    
    // Preserved copy of viewing mode from EventViewerViewController that specifies which segue to use when exiting the view controller
    var eventViewerExitSegueIndetifierCopy = ""
    
    // Preserves a user object if the segue to this view controller was called from a user profile
    var preservedUserObject = User()
    
    // Data provided to the table view.
    //
    // Data in the first component shows the cell type, "Input" means that the cell should have an input textfield,
    // and "TimeLabel" represents a cell that shows selected data and time.
    var fields = [
        ["Input", "Title"],
        ["Input", "Address"],
        ["Input", "Description"],
        ["TimeLabel", "Start Time"],
        ["TimeLabel", "End Time"],
        ["Input", "Attendee Limit"],
        ["Input", "Contact Email"]
    ]
    
    // Flag to show whether or not date picker cell is visible
    var datePickerDisplayed = false
    
    // Holds unique ID assigned to the date picker view from Storyboard
    let datePickerViewTag = 99
    
    // Holds the index of the start time cell
    let normalStartTimeDatePickerRow = 3
    
    // Holds the index of the end time cell
    let normalEndTimeDatePickerRow = 4
    
    // Holds event start time
    var eventStartTime = Date()
    
    // Holds event end time
    var eventEndTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update event start and end times with updated time from the passed event object
        eventStartTime  = event.startTime
        eventEndTime    = event.endTime
        
        // Save button will have different text depending on the viewing mode to either Create or Save an event
        if viewingMode == .Edit {
            saveNavigationBarButton.title = "Save"
        } else if viewingMode == .Create {
            saveNavigationBarButton.title = "Create"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func StartTimeDatePicker_ValueChanged(_ sender: UIDatePicker) {
        // Get the cell that contains event start time
        let cell = tableView.cellForRow(at: IndexPath(row: normalStartTimeDatePickerRow, section: 0))
        
        // Set the text of the time label to DatePicker's selected date value
        (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = DateTimeUtils.getEventDateAndTime(date: sender.date)
        
        // Update global state of event start time
        eventStartTime = sender.date
    }
    
    @objc func EndTimeDatePicker_ValueChanged(_ sender: UIDatePicker) {
        // Get the cell that contains event end time
        var endTimeIndexPath = IndexPath(row: normalEndTimeDatePickerRow, section: 0)
        
        // Check if start time date picker cell is expanded.
        // If so, incremenent end time row index by 1.
        if rowContainsDatePicker(indexPath: endTimeIndexPath) {
            endTimeIndexPath = IndexPath(row: normalEndTimeDatePickerRow + 1, section: 0)
        }
        
        // Get the cell that contains event end time
        let cell = tableView.cellForRow(at: endTimeIndexPath)
        
        // Set the text of the time label to DatePicker's selected date value
        (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = DateTimeUtils.getEventDateAndTime(date: sender.date)
        
        // Update global state of event end time
        eventEndTime = sender.date
    }
    
    func rowContainsDatePicker(indexPath: IndexPath) -> Bool {
        // Get the cell object at current index path
        let cell = tableView.cellForRow(at: indexPath)
        
        // Check if the cell contains a view with date picker's unique tag
        if cell?.viewWithTag(datePickerViewTag) != nil {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns number of rows in table view
        return fields.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        // Cell ID used to identify different cell types set in Storyboard
        var cellID = "eventTextBasedSettingsCell"
        
        //
        // Cell type is either:
        // "Input"      --> default cell with an input textfield,
        // "TimeLabel"  --> cell cotaining a label showing selected time, or
        // "DatePicker" --> expandable cell that contains DatePicker view
        //
        let cellType = fields[indexPath.row][0]
        
        // Set appropriate cell ID depending on the cell type
        if cellType == "TimeLabel" {
            cellID = "eventTimeBasedSettingsCell"
        } else if cellType == "DatePicker" {
            cellID = "datePickerCell"
        }
        
        // Deque the cell with appropriate cell identifier from the table view
        cell = tableView.dequeueReusableCell(withIdentifier: cellID)!
        
        // If the cell contains an input textfield
        if cellType == "Input" {
            
            // If the event is already created, set input textfield's text to the event's options.
            // Otherwise don't set the textfield's placeholder instead of the actual text.
            if viewingMode == .Create {
                (cell as! EventEditorTextBasedSettingsCell).inputTextfield.placeholder = getEventDataAsTextForCellRow(row: indexPath.row, event: event)
            } else {
                (cell as! EventEditorTextBasedSettingsCell).inputTextfield.text = getEventDataAsTextForCellRow(row: indexPath.row, event: event)
            }
            
            // If the row contains information about attendee limit, set keyboard type to number pad
            if fields[indexPath.row][1] == "Attendee Limit" {
                (cell as! EventEditorTextBasedSettingsCell).inputTextfield.keyboardType = .numberPad
            }
        }
        
        // If the cell contains a label showing selected time
        if cellType == "TimeLabel" {
            //
            // I honestly have no clue how I got these indices anymore.
            // If someone manages to make this more readable and understandable,
            // please update this comment to have actually useful information.
            //
            if indexPath.row == normalStartTimeDatePickerRow + 1 {
                (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = String(describing: DateTimeUtils.getEventDateAndTime(date: eventStartTime))
            } else {
                (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = String(describing: DateTimeUtils.getEventDateAndTime(date: eventEndTime))
            }
        }
        
        // If the cell contains the DatePicker view
        if cellType == "DatePicker" {
            let datePicker = (cell as! DatePickerCell).datePicker
            datePicker?.removeTarget(nil, action: nil, for: .allEvents) // remove all previously associated actions
            datePicker?.locale = Locale.autoupdatingCurrent
            
            // Setting callback target actions
            if indexPath.row == normalStartTimeDatePickerRow + 1 {
                datePicker?.addTarget(self, action: #selector(StartTimeDatePicker_ValueChanged(_:)), for: .valueChanged)
                datePicker?.setDate(eventStartTime, animated: true)
            } else {
                datePicker?.addTarget(self, action: #selector(EndTimeDatePicker_ValueChanged(_:)), for: .valueChanged)
                datePicker?.setDate(eventEndTime, animated: true)
            }
        }
        
        // For any cell, other than the cell containing date picker,
        // set the label text to second component of "fields" showing what information the cell has.
        if cellType != "DatePicker" {
            cell.textLabel?.text = (fields[indexPath.row][1] + ": ")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If the user clicks on the cell containing event START time
        if indexPath.row == normalStartTimeDatePickerRow {
            // Check if the next row contains start time date picker
            if rowContainsDatePicker(indexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
                // Hide UIDatePicker
                fields.remove(at: normalStartTimeDatePickerRow + 1)
                tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            } else {
                // Show UIDatePicker
                fields.insert(["DatePicker"], at: normalStartTimeDatePickerRow + 1)
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            }
        }
        
        // endTimeDatePickerRow will represent the proper current index for cell row that contains end time date picker
        var endTimeDatePickerRow = normalEndTimeDatePickerRow
        
        // If start time date picker cell is opened, increment the end time date picker index by 1
        if rowContainsDatePicker(indexPath: IndexPath(row: normalStartTimeDatePickerRow + 1, section: indexPath.section)) {
            endTimeDatePickerRow += 1
        }
        
        // If the user clicks on the cell containing event END time
        if indexPath.row == endTimeDatePickerRow {
            // Check if the next row contains end time date picker
            if rowContainsDatePicker(indexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
                // Hide UIDatePicker
                fields.remove(at: endTimeDatePickerRow + 1)
                tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            } else {
                // Show UIDatePicker
                fields.insert(["DatePicker"], at: endTimeDatePickerRow + 1)
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func SaveEventChanges_OnClick(_ sender: UIBarButtonItem) {
        // Either save changes of current event or create new one depending on the viewing mode
        
        let modifiedEvent = convertSettingsToEvent()
        
        if viewingMode == .Edit {
            UIUtils.showConfirmAlert(view: self, title: "Updating Event", message: "Are you sure you want to update current event?") { result in
                if result == true {
                    self.UpdateEvent(event: modifiedEvent)
                }
            }
        } else if viewingMode == .Create {
            UIUtils.showConfirmAlert(view: self, title: "Creating Event", message: "Are you sure you want to create new event?") { result in
                if result == true {
                    self.CreateEvent(event: modifiedEvent)
                }
            }
        }
    }
    
    @IBAction func CancelEventChanges_OnClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segues.CancelEventChanges, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! EventViewerViewController
        
        // Pass the preserved current identifier for the exit segue
        vc.exitSegueIdentifier = self.eventViewerExitSegueIndetifierCopy
        
        // Pass the preserved copy of the user
        vc.preservedUserObject = self.preservedUserObject
        
        // If the user clicks "Save" button, then pass newly customized event object.
        // If the user clicks "Cancel" button, then pass the initial, unchanged copy of event.
        if segue.identifier == Segues.SaveEventChanges {
            vc.event = convertSettingsToEvent() // returns new Event object with saved changes
            vc.viewingMode = .Edit
            
        } else if segue.identifier == Segues.CancelEventChanges {
            vc.event = self.event
            
            // Pass the preserved viewing mode state
            vc.viewingMode = self.viewingMode
        }
    }
    
    func convertSettingsToEvent() -> Event {
        func getRowTextfield(row: Int) -> UITextField {
            return (self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! EventEditorTextBasedSettingsCell).inputTextfield
        }
        
        var evt = Event()
        evt.latitude = self.event.latitude
        evt.longitude = self.event.longitude
        
        evt.title             = getRowTextfield(row: 0).text ?? "Title"
        evt.address           = getRowTextfield(row: 1).text ?? "Address"
        evt.description       = getRowTextfield(row: 2).text ?? "Description"
        evt.startTime         = eventStartTime
        evt.endTime           = eventEndTime
        evt.maxParticipants   = Int(getRowTextfield(row: 5).text ?? "0") ?? 0
        
        return evt
    }
    
    func getEventDataAsTextForCellRow(row: Int, event: Event) -> String {
        var result = "Not Specified"
        
        switch row {
        case 0:
            result = event.title
            break
        case 1:
            result = event.address
            break
        case 2:
            result = event.description
            break
        case 5:
            result = String(event.maxParticipants)
            break
        default:
            break
        }
        
        return result
    }
    
    private func CreateEvent(event: Event) {
        // Sends a request to the database to create a new event based on the current event object
        EventDataManager.shared.CreateNewEvent(view: self, event: event) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully created new event!") {
                    self.performSegue(withIdentifier: Segues.SaveEventChanges, sender: nil)
                }
            }
        }
    }
    
    private func UpdateEvent(event: Event) {
        // Sends updated event information to the database and updates the event
        EventDataManager.shared.ModifyEvent(event: event, view: self) { succeeded in
            if succeeded {
                UIUtils.showAlert(view: self, title: "Success", message: "Successfully updated event!") {
                    self.performSegue(withIdentifier: Segues.SaveEventChanges, sender: nil)
                }
            }
        }
    }
}

class EventEditorTextBasedSettingsCell : UITableViewCell, UITextFieldDelegate {
    
    var inputTextfield = UITextField()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initializeCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        inputTextfield.frame = CGRect(x: self.frame.width / 2, y: 0, width: self.frame.width / 2, height: self.frame.height)
    }
    
    private func initializeCell() {
        // Customize cell
        inputTextfield.delegate = self
        inputTextfield.placeholder = "Not Set"
        inputTextfield.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(inputTextfield)
    }
}

class EventEditorTimeBasedSettingsCell : UITableViewCell {
    
    var timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initializeCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        timeLabel.frame = CGRect(x: self.frame.width / 2, y: 0, width: self.frame.width / 2, height: self.frame.height)
    }
    
    private func initializeCell() {
        // Customize cell
        self.contentView.addSubview(timeLabel)
    }
}

class DatePickerCell : UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initializeCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func initializeCell() {
        // Customize cell
    }
}
