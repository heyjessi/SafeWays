//
//  EntireMapView.swift
//  SafeWay
//
//  Created by Hansen Qian on 7/12/15.
//  Copyright (c) 2015 HQ. All rights reserved.
//

import AFNetworking
import GoogleMaps
import SwiftyJSON
import UIKit

public class TextField: UITextField {

    public override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 10)
    }

    public override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 10)
    }
}

public class EntireMapView: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    let mapView = MapViewController()
    let textField = TextField()
    let locationManager = CLLocationManager()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.mapView.mapView.delegate = self
        self.textField.delegate = self
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    public override func viewDidLoad() {
        super.viewDidLoad()

        let bounds = CGRectMake(0, 0, self.view.bounds.width - 30, 48)
        println(bounds)
        let shadowPath = UIBezierPath(rect: bounds)
        self.textField.layer.masksToBounds = false
        self.textField.layer.shadowColor = UIColor.blackColor().CGColor
        self.textField.layer.shadowOffset = CGSizeMake(0, 0.5)
        self.textField.layer.shadowOpacity = 0.4
        self.textField.layer.shadowPath = shadowPath.CGPath
        self.textField.placeholder = "Placeholder here"
        self.textField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        self.textField.font = UIFont(name: "Avenir-Medium", size: 18)
        self.textField.returnKeyType = .Go
        self.textField.clearButtonMode = .WhileEditing

        self.mapView.view.addSubview(self.textField)
        self.view.addSubview(self.mapView.view)


        self.textField.snp_makeConstraints { [unowned self] make in
            make.top.left.right.equalTo(self.mapView.view).insets(UIEdgeInsetsMake(16, 16, 16, 16))
        }
        self.mapView.view.snp_makeConstraints { [unowned self] make in
            make.top.equalTo(self.view)
            make.left.right.bottom.equalTo(self.view)
        }
    }

    public func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        if self.textField.isFirstResponder() && gesture {
            self.textField.resignFirstResponder()
        }
        println("Hello!")
    }

    public func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let json = JSON(marker.userData)
        println("THIS IS THE MARKER!")
        println("\(json)")
        let saddr: String = json["legs"][0]["start_address"].stringValue.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let daddr: String = json["legs"][0]["end_address"].stringValue.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps://?directionsmode=walking&saddr=\(saddr)&daddr=\(daddr)")!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string:"http://maps.google.com/maps?directionsmode=walking&saddr=\(saddr)&daddr=\(daddr)")!)
        }
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != "" {
            request(textField)
        }
        return true
    }

    public func request(textField: UITextField) {
        let coord = self.locationManager.location.coordinate
        let originText = "\(coord.latitude), \(coord.longitude)"
        let destinationText = textField.text!
        let url = "http://chime.notifsta.com/directions"
        let parameters = [
            "start_address": originText,
            "end_address": destinationText,
        ]
        println("Requesting from url \(url)")
        AFHTTPRequestOperationManager().GET(url, parameters: parameters, success: { [unowned self] (operation, responseObj) -> Void in
            self.mapView.displayRoutes(JSON(responseObj))
            println("Response Succeeded!")
            }, failure: { (operation, error) -> Void in
            println("Error: \(error)")
        })
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
