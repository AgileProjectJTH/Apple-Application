//
//  LoginViewController.swift
//  CorridorApp
//
//  Created by Tim Hertzberg on 18/04/16.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginBtnClicked(sender: UIButton) {
        performSegueWithIdentifier("LoginToMainSegue", sender: nil)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginToMainSegue"{
            //let mainViewController = segue.destinationViewController as! MainViewController
        }
    }
 

}
