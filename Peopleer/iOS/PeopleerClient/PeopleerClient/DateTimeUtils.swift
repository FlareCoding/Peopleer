//
//  DateTimeUtils.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/26/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation

class DateTimeUtils {
    
    private static let _months = [
        "January", "February", "March", "April", "May", "June", "July", "August",
        "September", "October", "November", "December"
    ]
    
    static func getEventDateAndTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let stringDate: String = formatter.string(from: date as Date)
        let dateTimeString = stringDate.split(separator: " ")
        let dateComponents = dateTimeString[0].split(separator: "-")
        
        let monthString = _months[Int(String(describing: dateComponents[1]))!]
        let result = "\(dateTimeString[1]) \(monthString) \(dateComponents[0]) \(dateComponents[2])"
        return result
    }
    
    static func getEventDateAndTimeDBCompatFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date as Date)
    }
}
