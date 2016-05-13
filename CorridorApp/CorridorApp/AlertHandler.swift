//
//  AlertHandler.swift
//  CorridorApp
//
//  Created by Björn Hjelström on 2016-04-27.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import Foundation
import UIKit

class AlertHandler {
    
    let viewController:UIViewController
    
    init(viewController:UIViewController) {
        self.viewController = viewController
    }
    
    
    func showAlert(message:String, durationInSeconds:Double) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(durationInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                alert.dismissViewControllerAnimated(true, completion: nil);
            }
            self.viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    //OK-button
    func showAlert(message:String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in }))
            
            self.viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
}
