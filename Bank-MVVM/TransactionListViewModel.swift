//
//  TransactionListViewModel.swift
//  Bank-MVVM
//
//  Created by Adlai Holler on 2/16/15.
//  Copyright (c) 2015 Adlai Holler. All rights reserved.
//

import UIKit

// could be global
enum ContentState {
    case Initial
    case Loaded
    case Error(NSError)
    case Loading
}

class TransactionListViewModel: RVMViewModel {
    private(set) dynamic var title: String = "Loading…"
    private(set) dynamic var transactions: [TransactionViewModel] = []
    private(set) var contentState = ContentState.Initial
    // hack, because we can't use KVO on Swift enums. Don't fucking send to this if you're not this object!
    let contentStateChanges = RACSubject()
    let loadDataCommand: RACCommand
    
    override init() {
        loadDataCommand = RACCommand { _ in
            // pretend this comes from the server
            let hasError = false //(arc4random_uniform(100) > 75)
            if hasError {
                return RACSignal.error(NSError()).delay(2)
            } else {
                let transactions = TransactionViewModel.loadMockTransactionList()
                return RACSignal.`return`(transactions).delay(2)
            }
        }
        super.init()
        // whenever load data command sends a new array, set self.transactions
        loadDataCommand.executionSignals.switchToLatest().setKeyPath("transactions", onObject: self)
        loadDataCommand.executionSignals.switchToLatest().mapReplace("Sample Data").setKeyPath("title", onObject: self)
        
        // setup content state
        let startedLoadingSignal = loadDataCommand.executing.filter { ($0 as Bool) == true }
        let failedLoadingSignal = loadDataCommand.errors
        let didLoadSignal = loadDataCommand.executionSignals.switchToLatest()
        RACSignal.merge([ startedLoadingSignal, failedLoadingSignal, didLoadSignal ]).subscribeNext {[weak self] value in
            switch value {
            case is Bool: // must've started loading
                self!.setContentStateAndNotify(.Loading)
            case is NSError: // must've errored
                self!.setContentStateAndNotify(.Error(value as NSError))
            default: // must've succeeded
                self!.setContentStateAndNotify(.Loaded)
            }
        }
    }
    
    deinit {
        contentStateChanges.sendCompleted()
    }
    
    private func setContentStateAndNotify(newState: ContentState) {
        contentState = newState
        contentStateChanges.sendNext(RACUnit.defaultUnit())
    }
    
}
