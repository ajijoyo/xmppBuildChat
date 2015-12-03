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
    
    /** call when some buddy add you
     */
    func CHATnewBuddyRequest(JID : XMPPJID)
    
    func CHATdidDisconnect()
}

protocol xmppMessageDelegate : class{
    /** xmpp retrive message
     */
    func MESSAGEnewMessageReceive(message : AnyObject)
}

import UIKit

class xmppClientAppDelegate: NSObject , XMPPStreamDelegate {

    static let sharedInstance = xmppClientAppDelegate()
    
    weak var chatDelegate : xmppChatDelegate?
    weak var messageDelegate : xmppMessageDelegate? = nil
    
    internal var xmppStream : XMPPStream? = nil
    internal var roster : XMPPRoster?
    internal var password = ""
    
    var isOpen = false;
    
    private func SetupStream(){
        xmppStream = XMPPStream()
        xmppStream?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        roster = XMPPRoster(rosterStorage: XMPPRosterMemoryStorage())
        roster?.activate(xmppStream)
        if !roster!.autoFetchRoster {
            roster?.fetchRoster()
        }

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
        Log.D(message)
        let from = message.attributeForName("from").stringValue()
        if let msg = message.elementForName("body")?.stringValue()  {
            let m = ["msg":msg,"sender":from]
             messageDelegate?.MESSAGEnewMessageReceive(m)
        }
        
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if !(presenceFromUser == myUsername) {
            if presenceType == "available" {
                chatDelegate?.CHATnewBuddyOnline(presence.fromStr())
            }else if presenceType == "unavailable"{
                chatDelegate?.CHATnewBuddyOffline(presence.fromStr())
            }else if presenceType == "subscribe" {
                chatDelegate?.CHATnewBuddyRequest(presence.from())
            }
        }
        
        Log.D("\(presence.from()) \(presence.type())")
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        let queryElement = iq.elementForName("query", xmlns: "jabber:iq:roster")
        if queryElement != nil {
            let itemElements = queryElement.elementsForName("item")
            for atri in itemElements {
//                chatDelegate?.CHATnewBuddyOnline(((atri as? DDXMLElement)?.attributeForName("jid").stringValue())!)
            }
        }
        return true
    }
    
    func registration(){
        xmppStream?.myJID = XMPPJID.jidWithString("coba4@localhost")
        
        Log.D(xmppStream?.myJID.bare())
        
        if (xmppStream!.supportsInBandRegistration()) {
            do{
                _ = try xmppStream?.registerWithPassword("1234")
            }catch let error as NSError {
                Log.D(error)
            }
        }
        
    }
    
    func fetchFriends(){
        let query = DDXMLElement(name: "<query xmlns='jabber:iq:roster'/>")
        let iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
        
        iq.addAttributeWithName("type", stringValue: "get")
        iq.addAttributeWithName("id", stringValue: "ANY_ID_NAME")
        iq.addAttributeWithName("from", stringValue: "ANY_ID_NAME@localhost")
        iq.addChild(query)
        xmppStream?.sendElement(iq)
    }
    
    func xmppStreamDidRegister(sender: XMPPStream!) {
        
    }
    
    func xmppStream(sender: XMPPStream!, didNotRegister error: DDXMLElement!) {
        
    }

    
}
