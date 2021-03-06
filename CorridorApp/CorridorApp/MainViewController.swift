//
//  ViewController.swift
//  CorridorApp
//
//  Created by Mikael Sebastjan on 2016-04-08.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var slideInView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var mainViewXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var slideInViewController: SlideInViewController?
    var isSlideInVisible : Bool = false
    var isSlideInAnimating : Bool = false
    var slideInViewWidth : CGFloat = 0
    
    let dismissViewAlpha : CGFloat = 0.8 // How dark the overlay will be when the slideInView is showing (between 0-1.0)
    let animationTime : Double = 0.5 // How long the sliding animation will take.
    
    var firstTimeLoaded: Bool = true
    
    var isAvailable: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.firstTimeLoaded
        {
            self.firstTimeLoaded = false
            setUpViewController()
        }
        self.datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
        
        self.getAvailability()
    }
    
    func getAvailability() {
        let token = getToken()
        let date = self.getDateNow()
        
        self.view.userInteractionEnabled = false
        self.activityIndicatorView.startAnimating()
        
        HttpRequestRepository.getAvailability(token, date: String(date) , completion:{(responseS: NSString?, correct: Bool) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (!correct)
                {
                    self.activityIndicatorView.stopAnimating()
                    self.view.userInteractionEnabled = true
                    
                    self.logOut()
                    
                }
                else
                {
                    self.isAvailable = NSString(string:responseS!).boolValue
                    
                    self.activityIndicatorView.stopAnimating()
                    self.view.userInteractionEnabled = true
                    
                    self.setStartAvaibility()
                }
            })
        })
    }
    
    func getToken() -> String
    {
        let preferenses = NSUserDefaults.standardUserDefaults()
        let token = String(preferenses.valueForKey("token")!)
        if(token == "")
        {
            self.logOut()
        }
        return token
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func menuButtonClicked(sender: AnyObject) {
        if !isSlideInAnimating {
            self.animateSlideInView()
        }
    }
    
    //Return date from datepicker with format yyyy-mm-dd hh:mm:ss
    func getDate() -> String
    {
        var returnDate = ""
        
        if self.isAvailable == true
        {
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let year = calendar.components(.Year, fromDate: date).year
            let month = calendar.components(.Month, fromDate: date).month
            let day = calendar.components(.Day, fromDate: date).day
            var hour = calendar.components(.Hour, fromDate: date).hour
            var minute = calendar.components(.Minute, fromDate: date).minute
            let second = calendar.components(.Second, fromDate: date).second
            
            let unavailableForMinutes = (self.datePicker.countDownDuration / 60) % 60
            let unavailableForHours = floor(self.datePicker.countDownDuration / 3600)
            
            hour = hour + Int(unavailableForHours)
            minute = minute + Int(unavailableForMinutes)
            
            returnDate = String(year) + "-" + String(format: "%02d", month) + "-" + String(format: "%02d", day) + " " + String(format: "%02d", hour) + ":" + String(format: "%02d", minute) + ":" + String(format: "%02d", second)
        }
        else
        {
            var date = String(self.datePicker.date)
            let range = date.endIndex.advancedBy(-6)..<date.endIndex
            date.removeRange(range)
            returnDate = date
        }
        
        return returnDate
    }
    
    
    @IBAction func btnSetDatePicker(sender: AnyObject)
    {
        
        //User IS available and want to set automatic unavaibility after set time
        if self.isAvailable == true
        {
            let date = self.getDateNow()
            let schedule = ScheduleModel(from: date, to: self.getDate(), room: nil, course: nil, scheduleInfo: nil, avaiable: self.isAvailable)
            
            self.view.userInteractionEnabled = false
            self.activityIndicatorView.startAnimating()
            
            HttpRequestRepository.postAvailability(getToken(), schedule: schedule, completion:{(responseS: NSString?, correct: Bool) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alert = AlertHandler(viewController: self)
                    
                    if (!correct)
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("Error, try again!")
                    }
                        
                    else
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("You are now set to unavailable after the requested time")
                    }
                    
                })
                
            })

        }
            
        //User IS Unavailable and want to set automatic avaibility after set time
        else
        {
            let nsDate = NSDate()
            let date = String(nsDate)
            let d = date.startIndex.advancedBy(0)..<date.endIndex.advancedBy(-5)
            let schedule = ScheduleModel(from: date[d] , to: self.getDate(), room: nil, course: nil, scheduleInfo: nil, avaiable: self.isAvailable)
            
            self.view.userInteractionEnabled = false
            self.activityIndicatorView.startAnimating()
            
            HttpRequestRepository.postAvailability(getToken(), schedule: schedule, completion:{(responseS: NSString?, correct: Bool) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alert = AlertHandler(viewController: self)
                    
                    if (!correct)
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("Error, try again!")
                    }
                        
                    else
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("You are now set to unavailable to the requested date")
                    }
                })
                
            })

        }
    }
    
    @IBAction func buttonClicked(sender: AnyObject) {
        setAvaibility()
    }
    
    func logOut()
    {
        let preferenses = NSUserDefaults.standardUserDefaults()
        preferenses.setValue("", forKey: "token")
        preferenses.setValue("", forKey: "username")
        preferenses.setValue("", forKey: "password")
        preferenses.synchronize()
        performSegueWithIdentifier("segue_toLogin", sender: nil)
    }
    
    func setStartAvaibility()
    {
        if self.isAvailable == true
        {
            self.toolBarView.backgroundColor = UIColor.greenColor()
            self.datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
            self.mainButton.setTitle("Become Unavailable", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.redColor()
            self.infoLabel.text = "You are Available, tap to change status to Unavailable"
            self.setButton.setTitle("Set unavailable after time", forState: .Normal)
        }
            
        else
        {
            self.toolBarView.backgroundColor = UIColor.redColor()
            self.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            self.mainButton.setTitle("Become Available", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.greenColor()
            self.infoLabel.text = "You are Unavailable, tap to change status to Available"
            self.setButton.setTitle("Set unavailable until date", forState: .Normal)
        }

    }
    
    func setAvaibility()
    {
        if self.isAvailable == true
        {
            self.toolBarView.backgroundColor = UIColor.redColor()
            self.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            self.isAvailable = false
            self.mainButton.setTitle("Become Available", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.greenColor()
            self.infoLabel.text = "You are Unavailable, tap to change status to Available"
            self.setButton.setTitle("Set unavailable after time", forState: .Normal)
            
            let nsDate = NSDate()
            let date = String(nsDate)
            let d = date.startIndex.advancedBy(0)..<date.endIndex.advancedBy(-5)
            let schedule = ScheduleModel(from: date[d], to: date[d], room: nil, course: nil, scheduleInfo: nil, avaiable: isAvailable)
            
            self.view.userInteractionEnabled = false
            self.activityIndicatorView.startAnimating()
            
            HttpRequestRepository.postAvailability(getToken(), schedule: schedule, completion:{(responseS: NSString?, correct: Bool) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alert = AlertHandler(viewController: self)
                    
                    if (!correct)
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("Error, try again!")
                    }
                        
                    else
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("You are now set to unavailable!")
                    }
                })
                
            })

        }
            
        else
        {
            self.toolBarView.backgroundColor = UIColor.greenColor()
            self.datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
            self.isAvailable = true
            self.mainButton.setTitle("Become Unavailable", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.redColor()
            self.infoLabel.text = "You are Available, tap to change status to Unavailable"
            self.setButton.setTitle("Set unavailable until date", forState: .Normal)
            
            let nsDate = NSDate()
            let date = String(nsDate)
            let d = date.startIndex.advancedBy(0)..<date.endIndex.advancedBy(-5)
            let schedule = ScheduleModel(from: date[d], to: date[d], room: nil, course: nil, scheduleInfo: nil, avaiable: isAvailable)
            
            self.view.userInteractionEnabled = false
            self.activityIndicatorView.startAnimating()
            
            HttpRequestRepository.postAvailability(getToken(), schedule: schedule, completion:{(responseS: NSString?, correct: Bool) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alert = AlertHandler(viewController: self)
                    
                    if (!correct)
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("Error, try again!")
                    }
                        
                    else
                    {
                        self.activityIndicatorView.stopAnimating()
                        self.view.userInteractionEnabled = true
                        
                        alert.showAlert("You are now set to available!")
                    }
                })
                
            })

        }
    }
    
    func getDateNow() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let year = calendar.components(.Year, fromDate: date).year
        let month = calendar.components(.Month, fromDate: date).month
        let day = calendar.components(.Day, fromDate: date).day
        let hour = calendar.components(.Hour, fromDate: date).hour
        let minute = calendar.components(.Minute, fromDate: date).minute
        let second = calendar.components(.Second, fromDate: date).second
        
        let returnDate = String(year) + "-" + String(format: "%02d", month) + "-" + String(format: "%02d", day) + " " + String(format: "%02d", hour) + ":" + String(format: "%02d", minute) + ":" + String(format: "%02d", second)
        
        return returnDate
    }
    

    func setUpViewController() {
        //self.slideInViewWidth = self.slideInView.frame.width
        self.slideInViewWidth = UIScreen.mainScreen().bounds.width * 0.8
        
        let viewWidth = self.slideInView.frame.width
        let viewHeight = self.slideInView.frame.height
        
        // Instantiated the Slide In Menu and Home View Controllers.
        self.slideInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SlideInViewController") as? SlideInViewController
        
        // Makes it possible for the Slide In View Controller to communicate with the Container View Controller.
        if self.slideInViewController != nil {
            self.slideInViewController!.parent = self
            
            // Sets the Slide In Menu View.
            self.slideInView.addSubview(self.slideInViewController!.view)
            self.slideInViewController!.view.frame = CGRectMake(0, 0, viewWidth, viewHeight)
        }
        
        self.slideInView.hidden = false
        
        // Sets the Gesture Recognizers.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleTapGesture(_:)))
        self.dismissView.addGestureRecognizer(tapGestureRecognizer)
        self.dismissView.hidden = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handlePanGesture(_:)))
        let panGestureRecognizer2 = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handlePanGesture(_:)))
        self.mainView.addGestureRecognizer(panGestureRecognizer)
        self.slideInView.addGestureRecognizer(panGestureRecognizer2)
    }
    
    func menuOptionSelected(row: Int) {
        if row == 1 {
            self.logOut()
        }
        
        animateSlideInView()
    }

}

// MARK: Gestures
extension MainViewController: UIGestureRecognizerDelegate {
    // If the user pans on the Center View or Slide In View.
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if !isSlideInAnimating {
            switch(recognizer.state) {
            // When the user is touching the screen and panning.
            case .Changed:
                self.mainViewXConstraint.constant = self.mainViewXConstraint.constant + recognizer.translationInView(self.view).x
                recognizer.setTranslation(CGPointZero, inView: self.view)
                
                // Keeps the Slide In Menu from going to far in either horizontal direction.
                if self.mainViewXConstraint.constant < 0 {
                    self.mainViewXConstraint.constant = 0
                }
                else if self.mainViewXConstraint.constant > self.slideInViewWidth {
                    self.mainViewXConstraint.constant = self.slideInViewWidth
                }
                
                self.dismissView.hidden = false
                self.dismissView.alpha = self.dismissViewAlpha * (self.mainViewXConstraint.constant / self.slideInViewWidth)
                
            // When the user stops touching the screen.
            case .Ended:
                let hasMovedMoreThanHalfway = self.slideInView.center.x > 0
                
                if hasMovedMoreThanHalfway {
                    self.isSlideInVisible = false
                }
                else {
                    self.isSlideInVisible = true
                }
                animateSlideInView()
                
                break
                
            default:
                break
            }
        }
    }
    
    // If the user taps the Dismiss View.
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        if !isSlideInAnimating {
            animateSlideInView()
        }
    }
}

//MARK: Animations
extension MainViewController {
    //Animates the slideInView, to make it show or hide.
    func animateSlideInView() {
        self.view.endEditing(true)
        self.isSlideInAnimating = true
        if self.isSlideInVisible {
            UIView.animateWithDuration(self.animationTime, animations: { () -> Void in
                self.mainViewXConstraint.constant = 0
                self.dismissView.alpha = 0
                self.view.layoutIfNeeded()
                },
                                       completion: { finished in
                                        self.isSlideInVisible = false
                                        self.dismissView.hidden = true
                                        self.isSlideInAnimating = false
                }
            )
        }
        else {
            self.dismissView.hidden = false
            UIView.animateWithDuration(self.animationTime, animations: { () -> Void in
                self.mainViewXConstraint.constant = self.slideInViewWidth
                self.dismissView.alpha = self.dismissViewAlpha
                self.view.layoutIfNeeded()
                },
                                       completion: { finished in
                                        self.isSlideInVisible = true
                                        self.isSlideInAnimating = false
                }
            )
        }
    }
}

