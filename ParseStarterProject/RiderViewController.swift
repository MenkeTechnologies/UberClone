//
//  RiderViewController.swift
//  Uber
//
//  Created by Jacob Menke on 5/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate{
    
    var manager : CLLocationManager!
    var latitude : CLLocationDegrees = 0
    var longitude : CLLocationDegrees = 0
    var driverOnTheWay = false
    
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var callBut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
        
        callBut.layer.masksToBounds = false
        callBut.layer.cornerRadius = 2
        callBut.layer.shadowColor = UIColor.blackColor().CGColor
        callBut.layer.shadowOpacity = 1
        callBut.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        
        // Do any additional setup after loading the view.
    }
    
    func displayAert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let riderLocation : CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        latitude = riderLocation.latitude
        longitude = riderLocation.longitude
        
        
        var query = PFQuery(className:"riderRequest")
        
        query.whereKey("username", equalTo:(PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                
                
                
                
                if let objects = objects! as? [PFObject] {
                    
                    
                    if objects.count > 0 {
                        
                        
                        for object in objects {
                            
                            if let driverUsername = object["driverResponded"]{
                                self.callBut.setTitle("Driver is on the way", forState: UIControlState.Normal)
                                
                                
                                
                                var query = PFQuery(className:"driverLocation")
                                
                                
                                
                                query.whereKey("username", equalTo:driverUsername)
                                query.findObjectsInBackgroundWithBlock({ (objects, error) in
                                    if error == nil {
                                        
                                        
                                        
                                        
                                        if let objects = objects! as? [PFObject] {
                                            
                                            
                                            if objects.count > 0 {
                                                
                                                
                                                for object in objects {
                                                    
                                                    if let driverLocation = object["driverLocation"] as? PFGeoPoint {
                                                        
                                                        var driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                        var riderCLLocation = CLLocation(latitude: riderLocation.latitude, longitude: riderLocation.longitude)
                                                        
                                                        var distanceMeters = riderCLLocation.distanceFromLocation(driverCLLocation)
                                                        var distanceKM = distanceMeters / 1000
                                                        var roundedDistance = Double(round(distanceKM*10) / 10)
                                                        
                                                        
                                                       self.callBut.setTitle("Driver is \(roundedDistance) KM away", forState: UIControlState.Normal)
                                                        
                                                        self.driverOnTheWay = true
                                                        
                                                        let center = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                        
                                                        var latDelta = abs(driverLocation.latitude - riderLocation.latitude) * 2 + 0.005
                                                        var longDelta = abs(driverLocation.longitude - riderLocation.longitude) * 2 + 0.005

                                                        
                                                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
                                                        self.map.setRegion(region, animated: true)
                                                        self.map.removeAnnotations(self.map.annotations)
                                                        
                                                        var pinRiderLocation = CLLocationCoordinate2DMake(riderLocation.latitude, riderLocation.longitude)
                                                        var riderPin = MKPointAnnotation()
                                                        riderPin.coordinate = pinRiderLocation
                                                        riderPin.title = "Your Location"
                                                        
                                                        var pinDriverLocation = CLLocationCoordinate2DMake(driverLocation.latitude, driverLocation.longitude)
                                                        var driverPin = MKPointAnnotation()
                                                        driverPin.coordinate = pinDriverLocation
                                                        driverPin.title = "Driver Location"

                                                        
                                                        
                                                        self.map.addAnnotation(riderPin)
                                                        self.map.addAnnotation(driverPin)
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        
                                                     
                                                    }
                                                    
                                                    
                                                    
                                                }
                                            }
                                        }
                                    }
                                })
                                
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                            
                        }
                    }
                }
            }
        })
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        if driverOnTheWay == false {
        
        
        let center = CLLocationCoordinate2D(latitude: riderLocation.latitude, longitude: riderLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.removeAnnotations(map.annotations)
        
        
        let localePin = MKPointAnnotation()
        localePin.coordinate = center
        localePin.title = "Your Location"
        
        
        self.map.setRegion(region, animated: true)
        self.map.addAnnotation(localePin)
        
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutRider" {
            PFUser.logOut()
            var currentUser = PFUser.currentUser()
            
            
        }
    }
    
    
    
    
    var riderRequestActive = false
    
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
            
            let riderRequest = PFObject(className:"riderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
            
            
            riderRequest.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    
                    self.callBut.setTitle("Cancel Uber", forState: UIControlState.Normal)
                    
                    
                    
                } else {
                    
                    let alert = UIAlertController(title: "Could not call Uber", message: "Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    
                }
            }
            
            riderRequestActive = true
            
            
        } else {
            
            self.callBut.setTitle("Call an Uber", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            
            
            
            let query = PFQuery(className:"riderRequest")
            query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                if error == nil {
                    
                    
                    
                    if let objects = objects! as? [PFObject] {
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                        }
                    }
                } else {
                    
                    print(error)
                }
            })
            
            
        }
        
        
        
        
        
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
