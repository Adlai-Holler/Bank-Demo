//
//  TransactionCell.swift
//  Bank-MVVM
//
//  Created by Adlai Holler on 2/16/15.
//  Copyright (c) 2015 Adlai Holler. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    
    dynamic var viewModel: TransactionViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rac_valuesForKeyPath("viewModel.amountString", observer: self).setKeyPath("text", onObject: amountLabel)
        rac_valuesForKeyPath("viewModel.dateString", observer: self).setKeyPath("text", onObject: dateLabel)
        rac_valuesForKeyPath("viewModel.titleString", observer: self).setKeyPath("text", onObject: titleField)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let savedText = textField.text
        viewModel!.updateTitleCommand.execute(textField.text)
        .takeUntil(rac_prepareForReuseSignal)
        .subscribeError {_ in
            println("Error updating title of transaction.")
            // TODO: read actual title from viewModel
            return
        }
        textField.resignFirstResponder()
        return false
    }
}
