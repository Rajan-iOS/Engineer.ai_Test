//
//  DateGeneric.swift
//  Algolia_rajan_test
//
//  Created by PCQ143 on 11/12/19.
//  Copyright © 2019 tatvasoft. All rights reserved.
//

import Foundation

enum DateFormate {
    case serverDateFormate
    case appDateFormate
    
    var dateTitle : String{
        switch self {
        case .serverDateFormate:
            return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case .appDateFormate:
            return "E, d MMMM yyyy HH:mm:ss a"
        }
    }
}

enum TimeZoneEnum {
    case local
    case server
    
    var obj : TimeZone{
        switch self {
        case .local:
            return TimeZone.current
        case .server:
            return TimeZone(abbreviation: "UTC")!
        }
    }
}

struct PostDate {
    
    static func convertToString(fromdate: Date, formate: DateFormate, timezone: TimeZoneEnum = .local) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formate.dateTitle
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timezone.obj
        return formatter.string(from: fromdate)
    }
    
    static func convertToDate(fromStringDate: String, formate: DateFormate, timezone: TimeZoneEnum = .server) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate.dateTitle
        dateFormatter.timeZone = timezone.obj
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: fromStringDate) {
            return date
        }
        return nil
    }
}
