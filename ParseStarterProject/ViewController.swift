//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toggleSignupButton: UIButton!
    
    var signUpState = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
 
        return false
    }
    
    
    func displayAert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
}
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signUpAction(sender: AnyObject) {
        
        if userName.text == "" || passWord.text == ""{
            displayAert("Missing Fields", message: "Username and password are required")
        
        } else {
            
            let user = PFUser()
            user.username = userName.text
            user.password = passWord.text
            
            if signUpState == true {
           
            
            user["isDriver"] = `switch`.on
            
            
            user.signUpInBackgroundWithBlock({ (success, error) in
                if let error = error {
                    if let errorString = error.userInfo["error"] as? String{
                    self.displayAert("Sign up Failed", message: errorString )
                    }
                    
                } else {
                    
                    if self.`switch`.on == true {
                        
                        self.performSegueWithIdentifier("loginDriver", sender: self)
                        
                    } else {
                    
                    self.performSegueWithIdentifier("loginRider", sender: self)
                    
                    }
                    
                    
                }
                
            })
            
            }
            
            else {
                
                PFUser.logInWithUsernameInBackground(userName.text!, password: passWord.text!, block: { (user, error) in
                    if user != nil {
                  
                        if let user = user {
                            if user["isDriver"] as! Bool == true{
                                
                                self.performSegueWithIdentifier("loginDriver", sender: self)
                            }
                            else {
                                self.performSegueWithIdentifier("loginRider", sender: self)
                            }
                            
                        }
                        
                        
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                        
                    } else {
                        if let errorString = error?.userInfo["error"] as? String{
                            self.displayAert("Login Failed", message: errorString )
                        }

                    }
                })
            }
            
        }
        
    }
 
    @IBAction func toggleSignup(sender: AnyObject) {
        if signUpState == true {
            signUpButton.setTitle("Log In", forState: UIControlState.Normal)
            toggleSignupButton.setTitle("Switch to Sign Up", forState: UIControlState.Normal)
            signUpState = false
            
            riderLabel.alpha = 0
            driverLabel.alpha = 0
            `switch`.alpha = 0
                        
            
        } else {
            signUpButton.setTitle("Sign up", forState: UIControlState.Normal)
            toggleSignupButton.setTitle("Switch to Log In", forState: UIControlState.Normal)
            signUpState = true
            
            riderLabel.alpha = 1
            driverLabel.alpha = 1
            `switch`.alpha = 1
            
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser()?.username != nil {
            if PFUser.currentUser()?["isDriver"] as! Bool == true{
                
                self.performSegueWithIdentifier("loginDriver", sender: self)
            }
            else {
                self.performSegueWithIdentifier("loginRider", sender: self)
            }

        }
    }
    
    
    
    
}

