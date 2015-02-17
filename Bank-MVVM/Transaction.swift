//
//  Transaction.swift
//  Bank-MVVM
//
//  Created by Adlai Holler on 2/16/15.
//  Copyright (c) 2015 Adlai Holler. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    let amount: Int
    dynamic var title: String
    let date: NSDate

    init(dictionary: NSDictionary) {
        amount = dictionary["amount"] as Int
        title = dictionary["title"] as String
        date = dictionary["date"] as NSDate
        super.init()
    }
}
