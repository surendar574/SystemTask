//
//  ViewController.swift
//  TaskProject
//
//  Created by ravinder on 20/06/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var isFirst = true
    var isSecond = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 17.3850, longitude: 78.4867, zoom: 6.0)
        self.mapView?.animate(to: camera)
        self.mapView.settings.compassButton = true;
        self.mapView.settings.myLocationButton = true;
        self.mapView.isUserInteractionEnabled = true
        self.mapView.isMyLocationEnabled = true
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 19.0896, longitude: 72.8656)
        marker.title = "India"
        marker.snippet = "Mumbai Airport"
        marker.icon = GMSMarker.markerImage(with: UIColor.red)
        marker.map = self.mapView
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: 12.9941, longitude: 80.1709)
        marker2.title = "India"
        marker2.snippet = "Chennai Airport"
        marker2.icon = GMSMarker.markerImage(with: UIColor.blue)
        marker2.map = self.mapView
        
        //self.mapView = mapView
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        var addressString : String = ""
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    print(addressString)
                    
                    let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 6.0)
                    
                    // Creates a marker in the center of the map.
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                    marker.title = "India"
                    marker.snippet = addressString
                    marker.icon = GMSMarker.markerImage(with: UIColor.green)
                    marker.map = self.mapView
                    
                    self.mapView?.animate(to: camera)
                    
                    var destination1 = CLLocationCoordinate2D()
                    destination1.latitude = 19.0896
                    destination1.longitude = 72.8656
                    self.getPolylineRoute1(from: (location?.coordinate)!, to: destination1)
                    
                    var destination2 = CLLocationCoordinate2D()
                    destination2.latitude = 12.9941
                    destination2.longitude = 80.1709
                    self.getPolylineRoute2(from: (location?.coordinate)!, to: destination2)
                    
                  //  self.drawRectange(cordiantes: (location?.coordinate)!)
                }
        })
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }

    
    func drawRectange(cordiantes: CLLocationCoordinate2D){
        /* create the path */
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: cordiantes.latitude, longitude: cordiantes.longitude))
        path.add(CLLocationCoordinate2D(latitude: 12.9941, longitude: 80.1709))
        
        let path2 = GMSMutablePath()
        path2.add(CLLocationCoordinate2D(latitude: cordiantes.latitude, longitude: cordiantes.longitude))
        path2.add(CLLocationCoordinate2D(latitude: 19.0896, longitude: 72.8656))
        
        /* show what you have drawn */
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeColor = UIColor.orange
        rectangle.map = self.mapView
        
        let rectangle2 = GMSPolyline(path: path2)
        rectangle2.strokeColor = UIColor.orange
        rectangle2.map = self.mapView
    }
    
    // **********     Another One ********
    
    // Pass your source and destination coordinates in this method.
    func getPolylineRoute1(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        guard self.isFirst else {
            return
        }
        
        if isFirst{
            isFirst = false
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as! NSArray
                       // self.mapView.clear()
                        
                        OperationQueue.main.addOperation({
                            for route in routes
                            {
                                let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                let points = routeOverviewPolyline.object(forKey: "points")
                                let path = GMSPath.init(fromEncodedPath: points! as! String)
                                let polyline = GMSPolyline.init(path: path)
                                polyline.strokeColor = UIColor.orange
                                polyline.strokeWidth = 3
                                
                                let bounds = GMSCoordinateBounds(path: path!)
                                self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                                
                                polyline.map = self.mapView
                                
                            }
                        })
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    func getPolylineRoute2(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        guard self.isSecond else {
            return
        }
        
        if isSecond{
            isSecond = false
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as! NSArray
                        // self.mapView.clear()
                        
                        OperationQueue.main.addOperation({
                            for route in routes
                            {
                                let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                let points = routeOverviewPolyline.object(forKey: "points")
                                let path = GMSPath.init(fromEncodedPath: points! as! String)
                                let polyline = GMSPolyline.init(path: path)
                                polyline.strokeColor = UIColor.orange
                                polyline.strokeWidth = 3
                                
                                let bounds = GMSCoordinateBounds(path: path!)
                                self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                                
                                polyline.map = self.mapView
                                
                            }
                        })
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

