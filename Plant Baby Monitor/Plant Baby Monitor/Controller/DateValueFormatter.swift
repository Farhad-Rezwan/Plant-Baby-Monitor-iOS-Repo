//
//  DateValueFormatter.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/11/20.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    private let objects:[Status]
    
    init(objects: [Status]) {
        self.objects = objects
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value >= 0 && Int(value) < objects.count{
            let object = objects[Int(value)]
            
            var localDate: String = ""
            let timeResult = (object.timeStamp)
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            print(localDate)


            return dateFormatter.string(from: date)
        }
        return ""
    }
}
