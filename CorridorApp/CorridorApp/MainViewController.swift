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
    
    @IBOutlet weak var mainViewXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    
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
        
        if self.firstTimeLoaded {
            self.firstTimeLoaded = false
            setUpViewController()
        }
        
        self.isAvailable = true
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

