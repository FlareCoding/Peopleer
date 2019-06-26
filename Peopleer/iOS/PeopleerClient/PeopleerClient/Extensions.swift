//
//  Extensions.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/26/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

// Re-checks and corrects date if necessary
func correctDate(date: Date) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var comp = DateComponents()
    let calendar = Calendar.current
    comp.year = Calendar.current.component(.year, from: date)
    comp.month = Calendar.current.component(.month, from: date)
    comp.day = Calendar.current.component(.day, from: date)
    comp.hour = Calendar.current.component(.hour, from: date)
    comp.minute = Calendar.current.component(.minute, from: date)
    comp.second = Calendar.current.component(.second, from: date)
    comp.timeZone = TimeZone(abbreviation: "GMT")
    var dateFromCalendar = Date()
    if let calendarDate = calendar.date(from: comp) {
        dateFromCalendar = calendarDate
    }
    return dateFromCalendar
}

extension String {
    
    // Returns SHA-256 encrypted hash of a string
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    // Returns NSData digested data object
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    // Returns string representing hexadecimal form of NSData
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }

    // Converts String to Date
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.default
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Get NSDate for the given string
        return formatter.date(from: self)!
    }
    
    // Converts string to a Data object that is checked for correctness
    func toCorrectDate() -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.default
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Get NSDate for the given string
        let date = formatter.date(from: self)!
        return correctDate(date: date)
    }
    
}

extension UITextView {
    
    // Sets vertical allignment to a text view
    func alignTextVerticallyInContainer() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2.0
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }
    
    // Sets horizontal allignment to a text view
    func alignTextHorizontallyInContainer() {
        var leftCorrect = (self.bounds.size.width - self.contentSize.width * self.zoomScale) / 2.0
        leftCorrect = leftCorrect < 0.0 ? 0.0 : leftCorrect
        self.contentInset.left = leftCorrect
    }
    
}

extension UIFont {
    
    // Applies various traits to a font
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    var italic: UIFont {
        return withTraits(.traitItalic)
    }
    
    var bold: UIFont {
        return withTraits(.traitBold)
    }
}
