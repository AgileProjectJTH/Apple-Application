//
//  AccessTokenResponse.swift
//  CorridorApp
//
//  Created by Björn Hjelström on 2016-04-27.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import Foundation
class AccessTokenResponse
{
    //Konstruktor för AccessTokenResponse-object som kommer FRÅN backend
    init(jsonString:NSString)
    {
        if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        {
            let json = JSON(data: dataFromString)
            self.access_token = json["access_token"].string
            self.token_type = json["token_type"].string
            self.expires_in = json["expires_in"].int
        }
    }
    
    var access_token:String?
    var token_type:String?
    var expires_in:Int?
}