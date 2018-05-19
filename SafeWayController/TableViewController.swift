//
//  TableViewController.swift
//  SafeWay
//
//  Created by Hansen Qian on 7/11/15.
//  Copyright (c) 2015 HQ. All rights reserved.
//

import UIKit

public class TableViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource {

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required public init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}