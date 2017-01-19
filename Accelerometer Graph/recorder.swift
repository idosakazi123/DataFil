//
//  recorder.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 18/01/2017.
//  Copyright © 2017 Alex Gubbay. All rights reserved.
//

import Foundation
import UIKit

class recorder{
    
    var rawData = [accelPoint]()
    var processedData = [accelPoint]()
    
    func beginRecording(raw: Bool, processed: Bool, time: Double, complete: () -> Void){

        if raw{
            NotificationCenter.default.addObserver(self, selector: #selector(self.newRawData), name: Notification.Name("newRawData"), object: nil)
        }
        if processed {
            NotificationCenter.default.addObserver(self, selector: #selector(self.newProcessedData), name: Notification.Name("newProcessedData"), object: nil)
        }
        
        Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: {_ in
            //fire stopRecording method at end of time period
            self.stopRecording()
            
            })
    }
    
     @objc func newRawData(notification: NSNotification){
       let data = notification.userInfo as! Dictionary<String,accelPoint>
       let accelData = data["data"]
        rawData.append(accelData!)
        
    }
    
    func stopRecording(){
        print("stopping")
        print(rawData.count)
        print(processedData.count)
        NotificationCenter.default.removeObserver(self)
        
        let outputHeader = formatJSONheader()
        let outputData = formatJSONdata(header: outputHeader)
    }
    
    @objc func newProcessedData(notification: NSNotification){
        let data = notification.userInfo as! Dictionary<String,[accelPoint]>
        let accelData = data["data"]
        for point in accelData! {
            processedData.append(point)
        }
}
    
    func formatJSONheader()-> JSON{
        
        let today = NSDate()
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full
        
        let dateString = "{\"date\" : \""+dateFormatter.string(from: today as Date)+"\"}"
        
        let dateJson = dateString.data(using: .utf8, allowLossyConversion: false)
        var json = JSON(data: dateJson!)
        
     
        let filters = FilterManager.sharedInstance.activeFilters
        var filterData = [String:[String:Double]]()
        for filter in filters{
            filterData[filter.filterName] = filter.params
        }
        json["filters"] = JSON(filterData)
        
        return json
        
    }
    
    func formatJSONdata(header: JSON) -> JSON{
        var workingJSON = header

        
        var rawPoints = [[String:Double]]()
        var processedPoints = [[String:Double]]()
        
        for point in rawData{
           var pointDict = [String:Double]()
            pointDict["ID"] = Double(point.count)
            pointDict["x"] = point.x
            pointDict["y"] = point.y
            pointDict["z"] = point.z
            rawPoints.append(pointDict)

        }
        rawData.removeAll()
        
        for point in processedData{
            var pointDict = [String:Double]()
            pointDict["ID"] = Double(point.count)
            pointDict["x"] = point.x
            pointDict["y"] = point.y
            pointDict["z"] = point.z
            processedPoints.append(pointDict)
        }
        processedData.removeAll()
        
        workingJSON["raw"] = JSON(rawPoints)
        workingJSON["processed"] = JSON(processedPoints)
        
        print(workingJSON)
        return workingJSON
  
        
    }
    
    func saveRecording(){
    
    }
    
  deinit{
        //clean up observers
        NotificationCenter.default.removeObserver(self)
    }
}
