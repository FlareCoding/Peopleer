//
//  UserProfileViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 6/9/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    @IBOutlet weak var displayedNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userTableViewContentTypeSegmentedControl: UISegmentedControl!
    
    let kSegmentedControlHeight: CGFloat = 38
    
    private enum UserProfilePageTableViewContentCellType {
        case generalInformationCell
        case eventCell
    }
    
    private let userGeneralInformationTableViewContent = [
        "Country", "City", "Hours Volunteered", "Impact Points", "Contact Email"
    ]
    
    private var tableViewContentType = UserProfilePageTableViewContentCellType.generalInformationCell
    
    var user = User()
    var userEvents: [Event] = []
    
    var selectedEvent = Event()
    
//==============================================================================//
//==============================================================================//
//==============================================================================//
    
    override func viewDidLayoutSubviews() {
        self.userTableViewContentTypeSegmentedControl.frame = CGRect(x: userTableViewContentTypeSegmentedControl.frame.origin.x, y: userTableViewContentTypeSegmentedControl.frame.origin.y, width: userTableViewContentTypeSegmentedControl.frame.width, height: kSegmentedControlHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove table view separators by default
        tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.userTableViewContentTypeSegmentedControl.frame = CGRect(x: userTableViewContentTypeSegmentedControl.frame.origin.x, y: userTableViewContentTypeSegmentedControl.frame.origin.y, width: userTableViewContentTypeSegmentedControl.frame.width, height: kSegmentedControlHeight)
        
        displayedNameLabel.text = user.displayedName
        usernameLabel.text = user.username
        
        EventDataManager.shared.RetrieveEventsBasedOnFilter(view: self, eventSearchFilter: .owner, filter: user.username) { events in
            self.userEvents = events
        }
    }
    
    @IBAction func FollowUser_OnClick(_ sender: UIButton) {
        UIUtils.showAlert(view: self, title: "Followed \(user.username)", message: "")
    }
    
    @IBAction func userTableViewContent_ValueChanged(_ sender: UISegmentedControl) {
        let category = sender.titleForSegment(at: sender.selectedSegmentIndex)
        
        if category == "General" {
            tableViewContentType = .generalInformationCell
            tableView.allowsSelection = false
            tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        } else if category == "Events" {
            tableViewContentType = .eventCell
            tableView.allowsSelection = true
            tableView.separatorColor = .white
        }
        
        // reload table view data
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewContentType == .generalInformationCell {
            return userGeneralInformationTableViewContent.count
        } else if tableViewContentType == .eventCell {
            return userEvents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableViewContentType == .generalInformationCell {
            cell = tableView.dequeueReusableCell(withIdentifier: "generalInformationCell")!
            
            let labelTitleKey = userGeneralInformationTableViewContent[indexPath.row] + ": "
            (cell as! UserGeneralInformationCell).titleLabel.text = labelTitleKey
            
            switch indexPath.row {
            case 0:
                (cell as! UserGeneralInformationCell).dataLabel.text = user.country
                break
            case 1:
                (cell as! UserGeneralInformationCell).dataLabel.text = user.city
                break
            case 2:
               (cell as! UserGeneralInformationCell).dataLabel.text = String(user.hoursVolunteered)
                break
            case 3:
               (cell as! UserGeneralInformationCell).dataLabel.text = String(user.impact)
                break
            case 4:
                (cell as! UserGeneralInformationCell).dataLabel.font = (cell as! UserGeneralInformationCell).dataLabel.font.withSize(12.0)
                (cell as! UserGeneralInformationCell).dataLabel.text = user.email
                break
            default:
                break
            }
        }
        else if tableViewContentType == .eventCell {
            cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")!
            cell.textLabel?.font = UIFont(name: "Gill Sans", size: 20)
            cell.textLabel?.textColor = UIColor.white
            
            cell.textLabel?.text = userEvents[indexPath.row].title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableViewContentType == .eventCell {
            selectedEvent = userEvents[indexPath.row]
            performSegue(withIdentifier: Segues.ViewEvent, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ViewEvent {
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
            vc.exitSegueIdentifier = Segues.ReturnToUserProfile
            
            // Pass the user object to be preserved and passed back when returned back to this view controller
            vc.preservedUserObject = self.user
        }
    }
}

class UserGeneralInformationCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
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
