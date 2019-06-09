//
//  EventEditorViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 6/1/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class EventEditorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var viewingMode = EventViewerViewControllerViewingMode.Edit
    var event = Event()
    var eventViewerExitSegueIndetifierCopy = ""
    
    var fields = [
        ["Input", "Title"],
        ["Input", "Address"],
        ["Input", "Description"],
        ["TimeLabel", "Start Time"],
        ["TimeLabel", "End Time"],
        ["Input", "Attendee Limit"],
        ["Input", "Contact Email"]
    ]
    
    var datePickerDisplayed = false
    let datePickerViewTag = 99
    let normalStartTimeDatePickerRow = 3
    let normalEndTimeDatePickerRow = 4
    
    var eventStartTime = Date()
    var eventEndTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventStartTime  = event.startTime
        eventEndTime    = event.endTime
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func StartTimeDatePicker_ValueChanged(_ sender: UIDatePicker) {
        let cell = tableView.cellForRow(at: IndexPath(row: normalStartTimeDatePickerRow, section: 0))
        (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = DateTimeUtils.getEventDateAndTime(date: sender.date)
        eventStartTime = sender.date
    }
    
    @objc func EndTimeDatePicker_ValueChanged(_ sender: UIDatePicker) {
        var endTimeIndexPath = IndexPath(row: normalEndTimeDatePickerRow, section: 0)
        if rowContainsDatePicker(indexPath: endTimeIndexPath) {
            endTimeIndexPath = IndexPath(row: normalEndTimeDatePickerRow + 1, section: 0)
        }
        
        let cell = tableView.cellForRow(at: endTimeIndexPath)
        (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = DateTimeUtils.getEventDateAndTime(date: sender.date)
        eventEndTime = sender.date
    }
    
    func rowContainsDatePicker(indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.viewWithTag(datePickerViewTag) != nil {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        let cellType = fields[indexPath.row][0]
        var cellID = "eventTextBasedSettingsCell"
        
        if cellType == "TimeLabel" {
            cellID = "eventTimeBasedSettingsCell"
        } else if cellType == "DatePicker" {
            cellID = "datePickerCell"
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellID)!
        
        if cellType == "Input" {
            (cell as! EventEditorTextBasedSettingsCell).inputTextfield.text = getEventDataAsTextForCellRow(row: indexPath.row, event: event)
        }
        
        if cellType == "TimeLabel" {
            if indexPath.row == normalStartTimeDatePickerRow + 1 {
                (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = String(describing: DateTimeUtils.getEventDateAndTime(date: eventStartTime))
            } else {
                (cell as! EventEditorTimeBasedSettingsCell).timeLabel.text = String(describing: DateTimeUtils.getEventDateAndTime(date: eventEndTime))
            }
        }
        
        if cellType == "DatePicker" {
            // set callback actions
            if indexPath.row == normalStartTimeDatePickerRow + 1 {
                let datePicker = (cell as! DatePickerCell).datePicker
                datePicker?.removeTarget(nil, action: nil, for: .allEvents) // remove all previously associated actions
                datePicker?.addTarget(self, action: #selector(StartTimeDatePicker_ValueChanged(_:)), for: .valueChanged)
                datePicker?.setDate(eventStartTime, animated: true)
                datePicker?.locale = Locale.autoupdatingCurrent
            } else {
                let datePicker = (cell as! DatePickerCell).datePicker
                datePicker?.removeTarget(nil, action: nil, for: .allEvents) // remove all previously associated actions
                datePicker?.addTarget(self, action: #selector(EndTimeDatePicker_ValueChanged(_:)), for: .valueChanged)
                datePicker?.setDate(eventEndTime, animated: true)
                datePicker?.locale = Locale.autoupdatingCurrent
            }
        }
        
        if cellType != "DatePicker" {
            cell.textLabel?.text = (fields[indexPath.row][1] + ": ")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Start Time
        if indexPath.row == normalStartTimeDatePickerRow {
            if rowContainsDatePicker(indexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
                // hide UIDatePicker
                fields.remove(at: normalStartTimeDatePickerRow + 1)
                tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            } else {
                // show UIDatePicker
                fields.insert(["DatePicker"], at: normalStartTimeDatePickerRow + 1)
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            }
        }
        
        // End Time
        var endTimeDatePickerRow = normalEndTimeDatePickerRow
        if rowContainsDatePicker(indexPath: IndexPath(row: normalStartTimeDatePickerRow + 1, section: indexPath.section)) {
            endTimeDatePickerRow += 1
        }
        if indexPath.row == endTimeDatePickerRow {
            if rowContainsDatePicker(indexPath: IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
                // hide UIDatePicker
                fields.remove(at: endTimeDatePickerRow + 1)
                tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            } else {
                // show UIDatePicker
                fields.insert(["DatePicker"], at: endTimeDatePickerRow + 1)
                tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func SaveEventChanges_OnClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "saveEventChangesSegue", sender: nil)
    }
    
    @IBAction func CancelEventChanges_OnClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "cancelEventChangesSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! EventViewerViewController
        vc.viewingMode = self.viewingMode
        vc.exitSegueIdentifier = self.eventViewerExitSegueIndetifierCopy
        
        if segue.identifier == "saveEventChangesSegue" {
            vc.event = convertSettingsToEvent()
        } else if segue.identifier == "cancelEventChangesSegue" {
            vc.event = self.event
        }
    }
    
    func convertSettingsToEvent() -> Event {
        func getRowTextfield(row: Int) -> UITextField {
            return (self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! EventEditorTextBasedSettingsCell).inputTextfield
        }
        
        event.title             = getRowTextfield(row: 0).text ?? "Title"
        event.address           = getRowTextfield(row: 1).text ?? "Not Specified"
        event.description       = getRowTextfield(row: 2).text ?? "Not Specified"
        event.startTime         = eventStartTime
        event.endTime           = eventEndTime
        event.maxParticipants   = Int(getRowTextfield(row: 5).text ?? "0") ?? 0
        
        return event
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
