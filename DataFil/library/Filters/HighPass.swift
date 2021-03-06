//
//  HighPass.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 08/12/2016.
//  Copyright © 2016 Alex Gubbay. All rights reserved.
//
/*
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 The software implementation below is NOT designed to be used in any situation where the failure of the algorithms code on which they rely or mathematical assumptions made therin could lead to the harm of the user or others, property or the environment. It is NOT designed to prevent silent failures or fail safe.
 */

import Foundation

class HighPass: Filter{
    
    var params = [String:Double]()
    var filterName = Algorithm.HighPass
    var observers: [([accelPoint]) -> Void]
    var previousValue: accelPoint
    var previousRaw: accelPoint
    var sampleGap = 0.0
    var cutoff = 0.0
    var filterVal = 0.0
    var id = 0
    
    init(){

        params["sampleRate"] = 30.0
        params["cutoffFrequency"] = 40.0
        
        sampleGap = 1.0/(params["sampleRate"]!)
        cutoff = 1.0/(params["cutoffFrequency"]!)

        filterVal = cutoff/(sampleGap+cutoff)
        self.previousValue = accelPoint(dataX: 0.0, dataY: 0.0, dataZ: 0.0, count: 0)
        self.previousRaw = accelPoint(dataX: 0.0, dataY: 0.0, dataZ: 0.0, count: 0)
        observers = []
    }


    func setParameter(parameterName: String, parameterValue: Double) {
        
        params[parameterName] = parameterValue
        sampleGap = 1.0/(params["sampleRate"]!)
        cutoff = 1.0/(params["cutoffFrequency"]!)
        filterVal = cutoff/(sampleGap+cutoff)
    }
    
    func addDataPoint(dataPoint: accelPoint) -> Void {
        highPass(currentRaw: dataPoint)
    }
    
    func addObserver(update: @escaping ([accelPoint]) -> Void) {
        observers.append(update)
    }
    func notifyObservers(data: [accelPoint]) {
        for i in observers {
            i(data)
        }
    }
    
    func highPass(currentRaw: accelPoint){
        let newPoint = accelPoint()
        newPoint.xAccel = filterVal * (previousValue.xAccel + currentRaw.xAccel -  previousRaw.xAccel)
        newPoint.yAccel = filterVal * (previousValue.yAccel + currentRaw.yAccel -  previousRaw.yAccel)
        newPoint.zAccel = filterVal * (previousValue.zAccel + currentRaw.zAccel -  previousRaw.zAccel)
        
        newPoint.count = currentRaw.count
        previousValue = newPoint
        previousRaw = currentRaw
        notifyObservers(data: [newPoint])
    }
}
