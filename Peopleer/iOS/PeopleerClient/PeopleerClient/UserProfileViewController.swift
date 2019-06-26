//
//  UserProfileViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 6/9/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileGradientView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var user = User()
    
    var profileImageView: UIImageView!
    var usernameLabel: UILabel!
    var followButton: UIButton!
    
    private enum UserProfilePageTableViewContentCellType {
        case informationCell
        case eventCell
    }
    
    private let userGeneralInformationTableViewContent = [
        "Country", "City", "Hours Volunteered", "Impact Points"
    ]
    
    private var tableViewContentType = UserProfilePageTableViewContentCellType.informationCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for debug purposes set example user
        user = User(username: "Guest User", country: "United States", city: "New York", hoursVolunteered: 106, impact: 24760)
        
        addGradientLayerToProfileView()
        addProfileImageView()
        addUsernameLabel()
        addFollowButton()
    }
    
    //*** =========================================================================================================================== ***//
    //*** ========================================  METHODS FOR MANAGING USER INTERFACE ============================================= ***//
    
    func addGradientLayerToProfileView() {
        profileGradientView.translatesAutoresizingMaskIntoConstraints = false
        let layer = CAGradientLayer()
        layer.frame = profileGradientView.bounds
        layer.colors = [UIColor(red: 18 / 255, green: 46 / 255, blue: 102 / 255, alpha: 1).cgColor, UIColor(red: 50 / 255, green: 113 / 255, blue: 239 / 255, alpha: 1).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        profileGradientView.layer.addSublayer(layer)
    }
    
    func addProfileImageView() {
        profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "profileIcon")
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        profileGradientView.addSubview(profileImageView)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: (view.frame.height / 2) * -1 + 80).isActive = true
    }
    
    func addUsernameLabel() {
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        usernameLabel.textAlignment = NSTextAlignment.center
        
        profileGradientView.addSubview(usernameLabel)
        usernameLabel.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: (view.frame.height / 2) * -1 + 170).isActive = true
        
        usernameLabel.text = user.username
        usernameLabel.textColor = UIColor.white
        
        var descriptor = UIFontDescriptor(name: "Gill Sans", size: 26)
        descriptor = descriptor.addingAttributes([UIFontDescriptor.AttributeName.traits : [UIFontDescriptor.TraitKey.weight : UIFont.Weight.semibold]])
        usernameLabel.font = UIFont(descriptor: descriptor, size: 26)
    }
    
    func addFollowButton() {
        let buttonWidth: CGFloat = 140
        let buttonHeight: CGFloat = 30
        
        followButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
        followButton.translatesAutoresizingMaskIntoConstraints = false
        
        profileGradientView.addSubview(followButton)
        followButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        followButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        followButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: (view.frame.height / 2) * -1 + 220).isActive = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(UIColor.black, for: .normal)
        followButton.backgroundColor = UIColor(red: 30 / 255, green: 181 / 255, blue: 118 / 255, alpha: 1)
        
        followButton.layer.masksToBounds = false
        followButton.layer.cornerRadius = 16
        followButton.clipsToBounds = true
        
        followButton.addTarget(self, action: #selector(followButton_OnClick(_:)), for: .touchUpInside)
    }
    
    //*** =========================================================================================================================== ***//
    //*** ======================================  METHODS FOR UI ACTIONS AND CALLBACKS  ============================================= ***//
    
    @objc func followButton_OnClick(_ sender: UIButton) {
        UIUtils.showAlert(view: self, title: "Followed!", message: "")
    }
    
    //*** =========================================================================================================================== ***//
    //*** ========================================  METHODS FOR MANAGING TABLE VIEW  ================================================ ***//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewContentType == .informationCell {
            return userGeneralInformationTableViewContent.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableViewContentType == .informationCell {
            cell = tableView.dequeueReusableCell(withIdentifier: "informationCell")!
            
            cell.textLabel?.font = UIFont(name: "Gill Sans", size: 20)
            cell.textLabel?.textColor = UIColor.white
            
            let labelTitleKey = userGeneralInformationTableViewContent[indexPath.row] + ": "
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = labelTitleKey + user.country
                break
            case 1:
                cell.textLabel?.text = labelTitleKey + user.city
                break
            case 2:
                cell.textLabel?.text = labelTitleKey + String(user.hoursVolunteered)
                break
            case 3:
                cell.textLabel?.text = labelTitleKey + String(user.impact)
                break
            default:
                break
            }
        }
        
        return cell
    }
}
