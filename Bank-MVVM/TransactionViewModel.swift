//
//  TransactionViewModel.swift
//  Bank-MVVM
//
//  Created by Adlai Holler on 2/16/15.
//  Copyright (c) 2015 Adlai Holler. All rights reserved.
//

import UIKit

class TransactionViewModel: NSObject {
    private(set) dynamic var amountString: String
    private(set) dynamic var dateString: String
    private(set) dynamic var titleString: String
    let transaction: Transaction
    let updateTitleCommand: RACCommand
    init(transaction: Transaction) {
        let amountString =  NSMutableString(string: String(transaction.amount))
        amountString.insertString(".", atIndex: amountString.length - 2)
        self.amountString = "$" + amountString
        self.dateString = TTTTimeIntervalFormatter().stringForTimeIntervalFromDate(NSDate(), toDate: transaction.date)

        self.titleString = transaction.title
        self.transaction = transaction
        updateTitleCommand = RACCommand {
            let newTitle = $0 as String
            // pretend this is going to server
            let hasError =  false //(arc4random_uniform(100) > 75)
            if hasError {
                return RACSignal.error(NSError(domain: "placeholder", code: 100, userInfo: nil)).delay(2)
            } else {
                return RACSignal.empty().initially {
                    transaction.title = newTitle
                    return
                }.delay(2)
            }
        }
        super.init()
        transaction.rac_valuesForKeyPath("title", observer: self).setKeyPath("titleString", onObject: self)
    }
    
    class func loadMockTransactionList() -> [TransactionViewModel] {
        let infoArray = NSArray(contentsOfURL: NSBundle.mainBundle().URLForResource("SampleData", withExtension: "plist")!) as [NSDictionary]
        let transactions = infoArray.map { TransactionViewModel(transaction: Transaction(dictionary: $0)) }
        return transactions
    }
}
