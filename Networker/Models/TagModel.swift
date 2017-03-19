//
//  TagModel.swift
//  Networker
//
//  Created by Big Shark on 16/03/2017.
//  Copyright © 2017 shark. All rights reserved.
//

import UIKit

class TagModel: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var tag_id : Int64 = 0
    var tag_string = ""
    
    static let localTableName = ""
    static let localTableString = [
        Constants.KEY_TAG_ID : "TEXT",
        Constants.KEY_TAG_STRING : "TEXT"
    ]
    

}
