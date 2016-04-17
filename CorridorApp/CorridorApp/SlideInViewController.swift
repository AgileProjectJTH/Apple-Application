//
//  SlideInViewController.swift
//  CorridorApp
//
//  Created by Tim Hertzberg on 17/04/16.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import UIKit

class SlideInViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parent: UIViewController?
    
    var index: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (self.parent as? MainViewController) != nil {
            self.view.backgroundColor = UIColor.blackColor()
        }
        self.index = NSIndexPath(forRow: 0, inSection: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SlideInCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\((indexPath.row + 1))"
        
        cell.selectionStyle = .None
        
        if indexPath == index {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let p = self.parent as? MainViewController {
            p.menuOptionSelected(indexPath.row + 1)
        }
        self.index = indexPath
        tableView.reloadData()
    }

}
