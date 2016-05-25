//
//  LoginViewController.swift
//  CorridorApp
//
//  Created by Tim Hertzberg on 18/04/16.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var alertHandler:AlertHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        alertHandler = AlertHandler(viewController: self)
        // Do any additional setup after loading the view.
        
        let preferenses = NSUserDefaults.standardUserDefaults()
        let username = String(preferenses.valueForKey("username")!)
        let password = String(preferenses.valueForKey("password")!)
        if(!username.isEmpty && !password.isEmpty)
        {
            self.logIn(username, password: password)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginBtnClicked(sender: UIButton)
    {
        let username = usernameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let password = pwdTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // validate input
        if (username.isEmpty) {
            alertHandler.showAlert("Username is required.")
            return
        }
        if (password.isEmpty) {
            alertHandler.showAlert("Password is required.")
            return
        }
        
        self.view.userInteractionEnabled = false
        self.activityIndicatorView.startAnimating()
        
        let preferenses = NSUserDefaults.standardUserDefaults()
        preferenses.setValue(username, forKey: "username")
        // TODO: Keychain to safely store password?
        preferenses.setValue(password, forKey: "password")
        preferenses.synchronize()
        
        self.logIn(username, password: password)
    }
    
    func logIn(username: String, password: String){
        
        let ATR = AccessTokenRequest(username: username, password: password)
        HttpRequestRepository.getToken(ATR, completion:{(responseS: NSString?, correct: Bool) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (!correct)
                {
                    self.activityIndicatorView.stopAnimating()
                    self.view.userInteractionEnabled = true
                    self.alertHandler.showAlert("Wrong username or password")
                }
                else
                {
                    let atr = AccessTokenResponse(jsonString: responseS!)
                    let preferenses = NSUserDefaults.standardUserDefaults()
                    preferenses.setValue(atr.access_token!, forKey: "token")
                    preferenses.synchronize()
                    
                    self.activityIndicatorView.stopAnimating()
                    self.view.userInteractionEnabled = true
                    
                    self.performSegueWithIdentifier("LoginToMainSegue", sender: nil)
                }
            })
            
        })
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginToMainSegue"{
            //let mainViewController = segue.destinationViewController as! MainViewController
        }
    }
 

}
