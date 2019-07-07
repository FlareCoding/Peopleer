//
//  Segues.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 6/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation

struct Segues {
    
    // User segues
    static let ReturnToLoginScreen          = "returnToLoginScreenSegue"
    static let Logout                       = "logoutSegue"
    static let OpenMyProfile                = "openMyProfileSegue"
    static let ViewUserProfile              = "viewUserProfile"
    static let OpenMainMenu                 = "openMainMenuSegue"
    
    // Map segues
    static let ReturnToMapFromEventViewer   = "returnToMapSegue"
    static let OpenMap                      = "openMapSegue"
    
    // Event segues
    static let ViewMyEvents                 = "viewMyEventsSegue"
    static let ReturnToMyEvents             = "returnToMyEventsSegue"
    static let ReturnToUserProfile          = "returnToUserProfileSegue"
    static let ViewEvent                    = "viewEventSegue"
    static let EditEvent                    = "editEventSegue"
    static let SaveEventChanges             = "saveEventChangesSegue"
    static let CancelEventChanges           = "cancelEventChangesSegue"
    static let ReturnToEventViewerFromUserProfile = "returnToEventViewerFromUserProfileSegue"
}
