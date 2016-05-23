//
//  ViewController.swift
//  CorridorApp
//
//  Created by Mikael Sebastjan on 2016-04-08.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

//---------------------------------------------------TODO-------------------------------------------------------
//Functionen func getDate() -> String behöver skapas, hämtar ju olika info beroende på vilken picker som är tillgänglig DONE

//Meddelande när man har får svar från ett httprequest typ Visa ett meddelande vad man precis gjort DONE

//Lite mer info på skärmen vad diverse knapper excakt gör

//Erm se till så man inte kan göra flera httprequests samtidigt (en bool lära göra susen)

//Login ska funka Användarnama Boris lösenord password kan du använda för att logga in
//Spara mer info om användaren? Automatisk inloggning ifall session tagit slut och isf måste användarnamn och lösenord sparas

//OBS sätta avaibility/Unavaiblity kommer ej fungera för ens jag ändrat i APIet
//--------------------------------------------------------------------------------------------------------------




import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var slideInView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainViewXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    
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
        
        let token = getToken()
        let date = String("2016-04-27 14:44:08")
        
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
                    
                    self.setAvaibility()
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
        
        if(isAvailable == true)
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
            
            returnDate = String(year) + "-" + String(month) + "-" + String(day) + " " + String(hour) + ":" + String(minute) + ":" + String(second)
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
        
        //User IS avaiable and want to set automatic unavaibility after set time
        if isAvailable == true
        {
            let nsDate = NSDate()
            let date = String(nsDate)
            let d = date.startIndex.advancedBy(0)..<date.endIndex.advancedBy(-5)
            let schedule = ScheduleModel(from: date[d] , to: self.getDate(), room: nil, course: nil, scheduleInfo: nil, avaiable: isAvailable)
            
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
                        
                        alert.showAlert("You are now set to unavailable for the requested time")
                    }
                })
                
            })

        }
            
        //User IS Unavaiable and want to set automatic avaibility after set time
        else
        {
            let date = String("2016-04-27 14:44:08")
            let schedule = ScheduleModel(from: date, to: self.getDate(), room: nil, course: nil, scheduleInfo: nil, avaiable: isAvailable)
            
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
                        
                        alert.showAlert("You are now set to unavailable at the requested date")
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
        preferenses.synchronize()
        performSegueWithIdentifier("segue_toLogin", sender: nil)
    }
    
    func setAvaibility()
    {
        if self.isAvailable == true
        {
            self.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            self.isAvailable = false
            self.mainButton.setTitle("Available", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.greenColor()
            self.infoLabel.text = "You are Unavailable, tap to change status to Available"
            
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
            self.datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
            self.isAvailable = true
            self.mainButton.setTitle("Unvailable", forState: .Normal)
            self.buttonView.backgroundColor = UIColor.redColor()
            self.infoLabel.text = "You are Available, tap to change status to Unavailable"
            
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
        // TODO
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

