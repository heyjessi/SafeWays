//
//  MapViewController.swift
//  SafeWay
//
//  Created by Hansen Qian on 7/11/15.
//  Copyright (c) 2015 HQ. All rights reserved.
//

import GoogleMaps
import SwiftyJSON
import UIKit

class MyView : UIView {
    override func drawRect(rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()
        CGContextAddRect(c, CGRectMake(10, 10, 80, 80))
        CGContextSetStrokeColorWithColor(c , UIColor.redColor().CGColor)
        CGContextStrokePath(c)
    }
}

class MapViewController: UIViewController {

    let mapView: GMSMapView

    var polylines : Array<GMSPolyline>
    var markers: Array<GMSMarker>
    var json: JSON?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let cameraPosition = GMSCameraPosition.cameraWithLatitude(37.7771754, longitude: -122.4184106, zoom: 15)
        self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera: cameraPosition)
        self.markers = Array<GMSMarker>()
        self.polylines = Array<GMSPolyline>()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0)
        self.mapView.settings.compassButton = true
        self.mapView.myLocationEnabled = true
        self.mapView.settings.myLocationButton = true

        self.view = UIView()
        self.view.addSubview(self.mapView)
        self.mapView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayRoutes(json: JSON) {
        println("Displaying new routes!")
        self.json = json

        // Remove all current polylines
        self.polylines.map { [unowned self] line in
            line.map = nil
        }
        self.polylines = Array<GMSPolyline>()
        // Remove markers
        self.markers.map { [unowned self] marker in
            marker.map = nil
        }
        self.markers = Array<GMSMarker>()

        // Display Polylines
        var lines = Array<String>()
        for (index: String, obj: JSON) in json["routes"] {
            lines.append(obj["overview_polyline"]["points"].stringValue)
        }
        lines.map { [unowned self] line in
            self.displayPolyline(line, view: self.mapView, primary: line == lines.first)
        }
        let neLat = json["routes"][0]["bounds"]["northeast"]["lat"].doubleValue
        let neLng = json["routes"][0]["bounds"]["northeast"]["lng"].doubleValue
        let swLat = json["routes"][0]["bounds"]["southwest"]["lat"].doubleValue
        let swLng = json["routes"][0]["bounds"]["southwest"]["lng"].doubleValue
        let camera = self.mapView.cameraForBounds(
            GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(
                neLat,
                neLng
            ), coordinate: CLLocationCoordinate2DMake(
                swLat,
                swLng
            )), insets: UIEdgeInsetsMake(100, 100, 100, 100))
        self.mapView.animateToCameraPosition(camera)
        self.mapView.animateToZoom(calculateZoom(Float(neLat), neLng: Float(neLng), swLat: Float(swLat), swLng: Float(swLng)) - 0.25);

        // Display markers
        for (index: String, route: JSON) in json["routes"] {
            let lat = route["legs"][0]["via_waypoint"][0]["location"]["lat"].double ?? route["legs"][0]["end_location"]["lat"].double
            let lng = route["legs"][0]["via_waypoint"][0]["location"]["lng"].double ?? route["legs"][0]["end_location"]["lng"].double
            if lat != nil && lng != nil {
                let loc = CLLocationCoordinate2DMake(lat!, lng!)
                let marker = GMSMarker(position: loc)
                marker.title = route["summary"].stringValue
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.map = self.mapView
                marker.userData = route.object
                let score = floor(route["score"].doubleValue * 10000) / 100.0
                marker.snippet = "Safety Score: \(score)% \nTap again to open Google Maps."
                if index == "0" {
                    marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
                }
            }
        }
    }

    func calculateZoom(neLat: Float, neLng: Float, swLat: Float, swLng: Float) -> Float {
        var WORLD_DIM = [ "height": 256, "width": 256 ];
        var ZOOM_MAX: Float = 21;

        var latFraction = (latRad(neLat) - latRad(swLat)) / Float(M_PI);

        var lngDiff = neLng - swLng;
        var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

        var latZoom = zoom(Float(self.mapView.bounds.height), worldPx: Float(WORLD_DIM["height"]!), fraction: latFraction);
        var lngZoom = zoom(Float(self.mapView.bounds.width), worldPx: Float(WORLD_DIM["width"]!), fraction: lngFraction);
        
        return min(latZoom, min(lngZoom, ZOOM_MAX));
    }
    func latRad(lat: Float) -> Float {
        var sin1 = sin(lat * Float(M_PI) / 180);
        var radX2 = log((1 + sin1) / (1 - sin1)) / 2;
        return max(min(radX2, Float(M_PI)), Float(-M_PI)) / 2;
    }
    func zoom(mapPx: Float, worldPx: Float, fraction: Float) -> Float {
        return floor(log(mapPx / worldPx / fraction) / log(2));
    }

    func displayPolyline(line: String, view: GMSMapView, primary: Bool) {
        var line = GMSPolyline(path: GMSPath(fromEncodedPath: line))
        line.map = mapView
        line.strokeColor = (primary ? UIColor.blueColor() : UIColor.blackColor()).colorWithAlphaComponent(0.3)
        line.strokeWidth = 5
        self.polylines.append(line)
    }
}

