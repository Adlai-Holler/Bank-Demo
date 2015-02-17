//
//  TransactionListViewController.swift
//  Bank-MVVM
//
//  Created by Adlai Holler on 2/16/15.
//  Copyright (c) 2015 Adlai Holler. All rights reserved.
//

import UIKit

class TransactionListViewController: UITableViewController {
    let viewModel: TransactionListViewModel
    private var placeholderView: UIView?
    private var haveReceivedViewWillAppear = false
    
    // on load from storyboard
    required init(coder aDecoder: NSCoder) {
        viewModel = TransactionListViewModel()
        super.init(coder: aDecoder)
        viewModel.rac_valuesForKeyPath("title", observer: self).setKeyPath("title", onObject: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rac_liftSelector("updateLoadingUI:", withSignalsFromArray: [viewModel.contentStateChanges.startWith(nil)])
        
        viewModel
        .rac_valuesForKeyPath("transactions", observer: self)
        .takeUntil(rac_willDeallocSignal())
        .subscribeNext {[unowned self]_ in
            self.tableView.reloadData()
        }
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !haveReceivedViewWillAppear {
            haveReceivedViewWillAppear = true
            viewModel.loadDataCommand.execute(nil)
        }
        viewModel.active = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.active = false
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("transactionCell", forIndexPath: indexPath) as TransactionCell
        cell.viewModel = viewModel.transactions[indexPath.row]
        return cell
    }
    
    func updateLoadingUI(_: AnyObject?) {
        placeholderView?.removeFromSuperview()
        placeholderView = nil
        switch viewModel.contentState {
        case .Error(let nsError):
            placeholderView = UIView()
            let label = UILabel()
            label.text = "Error!" + nsError.localizedDescription
            placeholderView!.addSubview(label)
            label.autoCenterInSuperview()
        case .Loading:
            placeholderView = UIView()
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            spinner.startAnimating()
            placeholderView!.addSubview(spinner)
            spinner.autoCenterInSuperview()
        default: ()
        }
        if let newPlaceholder = placeholderView {
            newPlaceholder.frame = tableView.bounds
            tableView.tableHeaderView = newPlaceholder
            tableView.scrollEnabled = false
        } else {
            tableView.tableHeaderView = nil
            tableView.scrollEnabled = true
        }
    }
}
