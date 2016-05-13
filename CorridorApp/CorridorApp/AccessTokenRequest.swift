//
//  AccessTokenRequest.swift
//  CorridorApp
//
//  Created by Björn Hjelström on 2016-04-27.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import Foundation
class AccessTokenRequest
{
    //Constructor for AccessTokenRequest-object that will be sent to backend
    init(username:String, password:String)
    {
        self.username = username
        self.password = password
    }
    
    var username:String?
    var password:String?
}