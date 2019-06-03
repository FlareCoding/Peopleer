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
    
    let settings = ["Title", "Address", "Description", "Start Time", "End Time", "Attendee Limit", "Contact Email"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.row == 3 || indexPath.row == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "eventTimeBasedSettingsCell", for: indexPath)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "eventTextBasedSettingsCell", for: indexPath)
            (cell as! EventEditorTextBasedSettingsCell).inputTextfield.text = getEventDataAsTextForCellRow(row: indexPath.row, event: event)
        }
        
        cell.textLabel?.text = (settings[indexPath.row] + ": ")
        
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func SaveEventChanges_OnClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "saveEventChangesSegue", sender: nil)
    }
    
    @IBAction func CancelEventChanges_OnClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "cancelEventChangesSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveEventChangesSegue" {
            let vc = segue.destination as! EventViewerViewController
            vc.viewingMode = self.viewingMode
            vc.event = convertSettingsToEvent()
        }
        else if segue.identifier == "cancelEventChangesSegue" {
            let vc = segue.destination as! EventViewerViewController
            vc.viewingMode = self.viewingMode
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
    
    private func initializeCell() {
        // Customize cell
    }
}
