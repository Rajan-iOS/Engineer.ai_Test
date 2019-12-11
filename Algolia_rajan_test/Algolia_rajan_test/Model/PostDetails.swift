//
//  PostDetails.swift
//  Algolia_rajan_test
//
//  Created by PCQ143 on 11/12/19.
//  Copyright © 2019 tatvasoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostDetails: NSObject {
    var title = ""
    var createdDate = ""
    var isPostSelected = false
    
    required init(parameter: JSON) {
        if parameter.isEmpty != true {
            self.title = parameter["title"].stringValue
            
            if let createdDate = parameter["created_at"].string {
                let date = PostDate.convertToDate(fromStringDate: createdDate, formate: .serverDateFormate)
                self.createdDate = PostDate.convertToString(fromdate: date!, formate: .appDateFormate)
            }
        }
    }
}
