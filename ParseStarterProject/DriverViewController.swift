//
//  DriverViewController.swift
//  Uber
//
//  Created by Jacob Menke on 5/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverViewController: UITableViewController, CLLocationManagerDelegate{
    
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances  = [CLLocationDistance]()
    
    
    var manager : CLLocationManager!
    var latitude : CLLocationDegrees = 0
    var longitude : CLLocationDegrees = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    func displayAert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let driverLocation : CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = driverLocation.latitude
        self.longitude = driverLocation.longitude
        
        print("locations = \(driverLocation.latitude) \(driverLocation.longitude)")
        
        
        var query = PFQuery(className:"driverLocation")
        
        query.whereKey("username", equalTo:(PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                
                
                
                
                if let objects = objects! as? [PFObject] {
                    
                    
                    if objects.count > 0 {
                       

                        for object in objects {
                            
                            var query = PFQuery(className: "driverLocation")
                            query.getObjectInBackgroundWithId(object.objectId!, block: { (object, error) in
                                
                                if error != nil{
                                    print(error)
                                } else if let object = object{
                                    
                                    object["driverLocation"] = PFGeoPoint(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                    
                                    object.saveInBackground()
                                }
                                
                            })
                            
                            
                            
                        }
                        
                    } else {
                    
                    var driverLocationField = PFObject(className:"driverLocation")
                    driverLocationField["username"] = PFUser.currentUser()?.username
                    driverLocationField["driverLocation"] = PFGeoPoint(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    
                    driverLocationField.saveInBackground()
                    
                    }
                    
                    
                }
                
            } else {
                
                print(error)
            }
        })
        
        
        
        
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////// Location Query ////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////
        
        query = PFQuery(className:"riderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: driverLocation.latitude, longitude: driverLocation.longitude))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                
                if let objects = objects! as? [PFObject] {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        
                        if let username = object["username"] as? String {
                            self.usernames.append(username)
                        }
                        
                        if let returnedLocation = object["location"] as? PFGeoPoint {
                            let requestLocation = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                            
                            self.locations.append(requestLocation)
                            
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                            
                            let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                            
                            self.distances.append(distance/1000)
                            
                        }
                        
                        
                        
                    }
                    
                }
                
                
            } else {
                
                print(error)
            }
        })
        ////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////
        
        self.tableView.reloadData()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let unformatedDistance = distances[indexPath.row]
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        let num = NSNumber(double: unformatedDistance)
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.textLabel?.text = usernames[indexPath.row] + " is " + formatter.stringFromNumber(num)! + " km away from your location."
        
        // Configure the cell...
        
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutDriver" {
            
            PFUser.logOut()
            
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)
            
            
        } else if segue.identifier == "showViewRequests"{
            if let dest = segue.destinationViewController as? RequestViewController {
                dest.requestLocation = locations[tableView.indexPathForSelectedRow!.row]
                dest.requestUsername = usernames[tableView.indexPathForSelectedRow!.row]
            }
            
        }
        
        
        
    }
    
    
}
