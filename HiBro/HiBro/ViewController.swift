//
//  ViewController.swift
//  HiBro
//
//  Created by Dealjava on 12/1/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource ,xmppChatDelegate,xmppMessageDelegate{
    
    let xmpp = xmppClientAppDelegate.sharedInstance
    
    @IBOutlet weak var myTable : UITableView!
    
    var onlineBuddies :[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTable.rowHeight = 60;
        myTable.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
        
        xmpp.chatDelegate = self
        if (NSUserDefaults.standardUserDefaults().boolForKey("autoreply")){
            xmpp.messageDelegate = self
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("userID") {
            if (xmpp.connect()) {
                print("connected...")
            }
        }else{ // not login yet
            
        }
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        onlineBuddies.removeAll()
    }
    
    //MARK: - UItableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlineBuddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        cell.textLabel?.text = onlineBuddies[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Log.D(onlineBuddies[indexPath.row])
        let chatView = self.storyboard?.instantiateViewControllerWithIdentifier("chatviewSB") as! chatViewController
        chatView.toChatName = onlineBuddies[indexPath.row]
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    
    //MARK: - xmppChatDelegate 
    func CHATdidDisconnect() {
        
    }
    func CHATnewBuddyRequest(JID: XMPPJID) {
        
        let alert = UIAlertController(title: "approve pls", message: JID.user, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let addback = UIAlertAction(title: "i'll add you back", style: UIAlertActionStyle.Default, handler: {[unowned self](ac)in
            self.xmpp.roster?.acceptPresenceSubscriptionRequestFrom(JID, andAddToRoster: true)
        })
        let reject = UIAlertAction(title: "who the fucking are you?", style: UIAlertActionStyle.Cancel, handler: {[unowned self](ac)in
            self.xmpp.roster?.rejectPresenceSubscriptionRequestFrom(JID)
        })
        alert.addAction(reject)
        alert.addAction(addback)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    func CHATnewBuddyOffline(name: String) {
        onlineBuddies.removeObject(name)
        myTable.reloadData()
    }
    func CHATnewBuddyOnline(name: String) {
        onlineBuddies.append(name)
        myTable.reloadData()
    }
    
    func MESSAGEnewMessageReceive(message: AnyObject) {
        if let dic = message as? [String : String] {
            let body = DDXMLElement(name: "body")
            body.setStringValue("auto Bot")
            
            let message = DDXMLElement(name: "message")
            message.addAttributeWithName("type", stringValue: "chat")
            message.addAttributeWithName("to", stringValue: dic["sender"])
            message.addChild(body)
            
            xmpp.xmppStream?.sendElement(message)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

