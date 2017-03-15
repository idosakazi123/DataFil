//
//  watchCommunicator.swift
//  DataFil
//
//  Created by Alex Gubbay on 12/03/2017.
//  Copyright © 2017 Alex Gubbay. All rights reserved.
//

import Foundation
import WatchConnectivity


class remoteCommunicator: NSObject, WCSessionDelegate {

    static let sharedInstance = remoteCommunicator()
    var watchObservers: [String: [(Any) -> Void]]
    var delegates = [AnyObject]()
    var session = WCSession.default()
    var deviceId = "unknown"

    func start(deviceId: String){
        self.deviceId = deviceId
        if WCSession.isSupported() {
            if session.hasContentPending{
                print("may have old data")
            }
            session.delegate = self
            session.activate()
            session = WCSession.default()
            print("comms live on \(deviceId)")
        }else{
            print("coms not supported on \(deviceId)")
        }
    }
    override init(){

        watchObservers = [:]
    }
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?){
    }
    
    func isSupported() -> Bool{
        return WCSession.isSupported()
    }
    

    #if os(iOS)
    func sessionDidDeactivate(_ session: WCSession) {
        //ERM
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        //Do some stuff here I gueess
    }
    #endif
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        //
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

        for k in message.keys{
            notifyObservers(key: k, data: message[k] as Any)
        }
    }

    func sendMessage(key: String, value: Any){

        if (session.isReachable) {
            let message = [key: value]
            session.sendMessage(message, replyHandler: nil)
        }else{
            print("remote unreachable from \(deviceId)")
        }
    }
    
    func watchIsConnected() -> Bool{
        
        return !session.isReachable
      
    }

    func addObserver(key: String, update: @escaping (Any) -> Void) {
        DispatchQueue.main.async {
            if var value = self.watchObservers[key]{
                value.append(update)
            }else{
                self.watchObservers[key] = [update]
            }
        }
    }

    func notifyObservers(key: String, data: Any) {

        if let registeredObservers = watchObservers[key]{

            for i in registeredObservers {
                i(data)
            }
        }
    }
}