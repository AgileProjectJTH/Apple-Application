//
//  ViewController.swift
//  CorridorApp
//
//  Created by Mikael Sebastjan on 2016-04-08.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    
    var isAvailable: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.isAvailable = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonClicked(sender: AnyObject) {
        
        if self.isAvailable == true {
            self.isAvailable = false
            self.mainButton.setTitle("Available", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.greenColor()
            self.infoLabel.text = "You are Unavailable, tap to change status to Available"
        }
        else {
            self.isAvailable = true
            self.mainButton.setTitle("Unvailable", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.redColor()
            self.infoLabel.text = "You are Available, tap to change status to Unavailable"
        }
    }

}

