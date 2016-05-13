//
//  HttpRequest.swift
//  CorridorApp
//
//  Created by Björn Hjelström on 2016-04-27.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import Foundation
class HttpRequestRepository
{
    static var apiUrl =  "http://193.10.30.155/CorridorAPI/"
    
    //Try to login and get token for this session
    static func getToken(accessTokenRequest:AccessTokenRequest, completion: (responseS: NSString?, correct: Bool) -> Void)
    {
        let postString="grant_type=password&username=\(accessTokenRequest.username!)&password=\(accessTokenRequest.password!)"
        startHttpRequest(
            NSURL(string:apiUrl+"token"),
            method: "POST",
            contentType: nil,
            body: postString,
            token: nil,
            completion:{(responseS: NSString?,correct:Bool) -> Void in
                
                completion(responseS: responseS, correct: correct)
            }
        )
    }
    
    //get current users avaibility
    static func getAvailability(token:String?, date:String?,completion: (responseS: NSString?, correct: Bool) -> Void)
    {
        let tok = "bearer \(token!)"
        startHttpRequest(
            NSURL(string:(apiUrl+"Api/Staff?dateAndTime=\(date!)").stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!),
            method: "GET",
            contentType: "application/json; charset=utf-8",
            body: nil,
            token: tok,
            completion:{(responseS: NSString?,correct:Bool) -> Void in
                completion(responseS: responseS, correct: correct)
            }
        )
    }
    
    //sets current users avaibility to specifik date/time
    //TODO hur skickar vi med date?
    static func postAvailability(token:String?,schedule:ScheduleModel?,completion: (responseS: NSString?, correct: Bool) -> Void)

    {
        let tok = "bearer \(token!)"
        startHttpRequest(
            NSURL(string:apiUrl+"API/Schedule"),
            method: "POST",
            contentType: "application/json; charset=utf-8",
            body: schedule?.toJson(),
            token: tok,
            completion:{(responseS: NSString?,correct:Bool) -> Void in
                completion(responseS: responseS, correct: correct)
            }
        )
    }
    
    
    static func startHttpRequest(url:NSURL?, method:String?, contentType:String?, body:String?, token:String? , completion: (responseS: NSString?, correct: Bool) -> Void)
    {
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method!
        
        if body != nil
        {
            request.HTTPBody = body!.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if token != nil
        {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
        {
            data, response, error in
            
            //if something went wrong do this
            if error != nil
            {
                return
            }
            
            if let httpresponse: NSHTTPURLResponse = response as? NSHTTPURLResponse {
                let statuscode = httpresponse.statusCode
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                //if statuscode is 200 everything is good so continue
                if statuscode == 200
                {
                    completion(responseS: responseString!, correct: true);
                }
                //else something is wrong, do something
                else
                {
                    completion(responseS: responseString!, correct: false)
                }
            }
        }
        task.resume()
    }
}