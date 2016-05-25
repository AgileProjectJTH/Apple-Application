//
//  ScheduleModel.swift
//  CorridorApp
//
//  Created by Björn Hjelström on 2016-05-13.
//  Copyright © 2016 Mikael Sebastjan. All rights reserved.
//

import Foundation
class ScheduleModel
{
    init(from:String?, to:String?, room:String?, course:String?, scheduleInfo:String?, avaiable:Bool?
)
    {
        self.fromDateAndTime = from
        self.toDateAndTime = to
        self.roomNr = room
        self.course = course
        self.scheduleInfo = scheduleInfo
        self.available = avaiable
    }
    
    func toJson() ->String!
    {
        //Skapa json-strukturen
        let json = JSON([
            "fromDateAndTime":self.fromDateAndTime!,
            "toDateAndTime":self.toDateAndTime!,
            "available": self.available!
            ])
        //Konvertera json-objektet till en sträng
        return json.rawString()
    }

    var fromDateAndTime:String?
    var toDateAndTime:String?
    var roomNr:String?
    var course:String?
    var scheduleInfo:String?
    var available:Bool?
}