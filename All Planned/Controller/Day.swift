//
//  Days.swift
//  All Planned
//
//  Created by Lam Nguyen on 2/1/21.
//

import Foundation

class Day{
    var name: String!
    var dayDate: String!
    var clicked: Bool!
    
    init(name: String, dayDate: String, clicked: Bool){
        self.name = name
        self.dayDate = dayDate
        self.clicked = clicked
    }
}
