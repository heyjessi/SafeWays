//
//  InputViewController.swift
//  SafeWay
//
//  Created by Hansen Qian on 7/11/15.
//  Copyright (c) 2015 HQ. All rights reserved.
//

import AFNetworking
import ReactiveCocoa
import SnapKit
import SwiftyJSON
import UIKit


class InputViewController: UIViewController {

    let insets = UIEdgeInsetsMake(10, 10, 10, 10)

    let originTextField: UITextField
    let destinationTextField: UITextField
    let submitButton: UIButton
//    let tableViewController: TableViewController

    let buttonPressedSignal: Signal<(String, String), NoError>
    let buttonPressedObserver: Signal<(String, String), NoError>.Observer
    var mvc: MapViewController?
    var tbc: UITabBarController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.originTextField = UITextField()
        self.destinationTextField = UITextField()
        self.submitButton = UIButton()
//        self.tableViewController = TableViewController()
        (self.buttonPressedSignal, self.buttonPressedObserver) = Signal<(String, String), NoError>.pipe()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)   
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.originTextField.placeholder = "Enter Origin"
        self.originTextField.text = "116 New Montgomery St., San Francisco, CA"
        self.destinationTextField.text = "549 Connecticut St., San Francisco, CA"
        self.destinationTextField.placeholder = "Enter Destination"
        self.submitButton.setTitle("Search!", forState: .Normal)
        self.submitButton.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.3)
        self.submitButton.tintColor = UIColor.blueColor()
        self.submitButton.addTarget(self, action: NSSelectorFromString("buttonPressed"), forControlEvents: .TouchUpInside)

        self.view.addSubview(self.originTextField)
        self.view.addSubview(self.destinationTextField)
        self.view.addSubview(self.submitButton)

        // Customize tableView
//        self.view.addSubview(self.tableViewController)

        self.originTextField.snp_makeConstraints { [unowned self] make in
            make.top.equalTo(self.view).insets(UIEdgeInsetsMake(50, 0, 0, 0))
            make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 20, 0, 20))
        }
        self.destinationTextField.snp_makeConstraints { [unowned self] make in
            make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 20, 0, 20))
            make.top.equalTo(self.originTextField).insets(UIEdgeInsetsMake(40, 0, 0, 0))
        }
        self.submitButton.snp_makeConstraints { [unowned self] make in
            make.top.equalTo(self.destinationTextField).insets(UIEdgeInsetsMake(40, 0, 0, 0))
            make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 20, 0, 20))
        }
    }

    func buttonPressed() {
        println("Button Pressed!")
        if self.originTextField.text != "" && self.destinationTextField != "" {
//            sendNext(self.buttonPressedObserver, (self.originTextField.text, self.destinationTextField.text))
            let originText = self.originTextField.text!
            let destinationText = self.destinationTextField.text!
            let url = "http://chime.notifsta.com/directions"
            let parameters = [
                "start_address": originText,
                "end_address": destinationText,
            ]
            println("Requesting from url \(url)")
            AFHTTPRequestOperationManager().GET(url, parameters: parameters, success: { [unowned self] (operation, responseObj) -> Void in
                self.mvc?.displayRoutes(JSON(responseObj))
                self.tbc?.selectedIndex = 1
            }, failure: { (operation, error) -> Void in
                println("Error: \(error)")
            })
        }
    }

    func displayResults(responseObj: JSON) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

