//
//  xmppClientAppDelegate.swift
//  HiBro
//
//  Created by Dealjava on 12/1/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

protocol xmppChatDelegate : class{
    /** call when budy get online
     */
    func CHATnewBuddyOnline(name : String)
    /** call when budy get offline
     */
    func CHATnewBuddyOffline(name : String)
    func CHATdidDisconnect()
}

protocol xmppMessageDelegate : class{
    /** xmpp retrive message
     */
    func MESSAGEnewMessageReceive(message : AnyObject)
}

import UIKit

class xmppClientAppDelegate: NSObject , XMPPStreamDelegate{

    static let sharedInstance = xmppClientAppDelegate()
    
    weak var chatDelegate : xmppChatDelegate?
    weak var messageDelegate : xmppMessageDelegate? = nil
    
    internal var xmppStream : XMPPStream? = nil
    internal var password = ""
    
    var isOpen = false;
    
    private func SetupStream(){
        xmppStream = XMPPStream()
        xmppStream?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
    }
    
    private func goOnline(){
        let preference = XMPPPresence()
        xmppStream?.sendElement(preference)
        
    }
    
    private func goOffline(){
        let preference = XMPPPresence(type: "unavailable")
        xmppStream?.sendElement(preference)
    }
    
    /**
     * Disconnect from server
     */
    internal func disconnect(){
        self.goOffline()
        xmppStream?.disconnect()
    }
    /**
     * Connect to Server
     */
    internal func connect() -> Bool{
        self.SetupStream()
        let xmppID = NSUserDefaults.standardUserDefaults().stringForKey("userID")! as String
        let xmppPass = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")! as String
        
        if (!xmppStream!.isDisconnected()) {
            return true;
        }
        
        if (xmppID.isEmpty || xmppPass.isEmpty) {
            
            return false;
        }
        xmppStream!.myJID = XMPPJID.jidWithString(xmppID)
        password = xmppPass;
        do{
            _ = try xmppStream?.connectWithTimeout(30)
        }catch _ as NSError{
            let alert = UIAlertController(title: "Error", message: "Can't connect to server ", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelbttn = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler:nil)
            alert.addAction(cancelbttn)
            return false
        }

        return true;
    }
    
    //MARK: - XMPPStreamDelegate
    func xmppStreamDidConnect(sender: XMPPStream!) {
        isOpen = true
        do{
            _ = try xmppStream?.authenticateWithPassword(password)

        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {

        let msg = message.elementForName("body").stringValue()
        let from = message.attributeForName("from").stringValue()
        
        let m = ["msg":msg,"sender":from]
        
        messageDelegate?.MESSAGEnewMessageReceive(m)
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if !(presenceFromUser == myUsername) {
            if presenceType != "unavailable" {
                chatDelegate?.CHATnewBuddyOnline(presence.fromStr())
            }else if presenceType == "unavailable"{
                chatDelegate?.CHATnewBuddyOffline(presence.fromStr())
            }
        }
    }
    
}
