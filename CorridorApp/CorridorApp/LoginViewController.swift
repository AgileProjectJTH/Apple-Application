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
    var alertHandler:AlertHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        alertHandler = AlertHandler(viewController: self)
        // Do any additional setup after loading the view.
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
        
        let ATR = AccessTokenRequest(username: username, password: password)
        HttpRequestRepository.getToken(ATR, completion:{(responseS: NSString?, correct: Bool) -> Void in
            
            if (!correct)
            {
                self.alertHandler.showAlert("Wrong username or password")
            }
            else
            {
                let atr = AccessTokenResponse(jsonString: responseS!)
                let preferenses = NSUserDefaults.standardUserDefaults()
                preferenses.setValue(atr.access_token, forKey: "token")
                preferenses.synchronize()
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("LoginToMainSegue", sender: nil)
                })
                
            }
            
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
