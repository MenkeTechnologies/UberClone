//
//  RequestViewController.swift
//  Uber
//
//  Created by Jacob Menke on 5/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var requestLocation  = CLLocationCoordinate2D()
    var requestUsername = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        let localePin = MKPointAnnotation()
        localePin.coordinate = requestLocation
        localePin.title = requestUsername
        
        
        self.map.setRegion(region, animated: true)
        self.map.addAnnotation(localePin)
        
        
        // Do any additional setup after loading the view.
    }
    
    func displayAert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            print("pressed ok")
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func pickUpRider(sender: AnyObject) {
        
        let query = PFQuery(className:"riderRequest")
        
        query.whereKey("username", equalTo:requestUsername)
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                
                
                if let objects = objects! as? [PFObject] {
                    
                    for object in objects {
                        
                        //                        if object["driverResponded"] == nil {
                        
                        object["driverResponded"] = PFUser.currentUser()!.username!
                        
                        
                        do { try object.save()
                            self.displayAert("Success", message: "Rider \(self.requestUsername) has been alerted")
                            
                        }
                            
                        catch {
                            print("Unable to save")
                        }
                        
                        let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                        
                        CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                            
                            if error != nil {
                                print("There was an error with Geocoder " + error!.localizedDescription)
                            } else {
                                if placemarks?.count > 0{
                                    let pm = placemarks![0]
                                    let mkPM = MKPlacemark(placemark: pm)
                                    
                                    let mapItem = MKMapItem(placemark: mkPM)
                                    mapItem.name = self.requestUsername
                                    
                                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                                    
                                    
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                            
                            
                            
                            
                        })
                        
                 
                        
                        //                        } else {
                        //                            self.displayAert("Error", message: "Rider \(self.requestUsername) already accounted for")
                        //                        }
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


