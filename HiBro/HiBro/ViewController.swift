//
//  ViewController.swift
//  HiBro
//
//  Created by Dealjava on 12/1/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource ,xmppChatDelegate{
    
    let xmpp = xmppClientAppDelegate.sharedInstance
    
    @IBOutlet weak var myTable : UITableView!
    
    var onlineBuddies :[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTable.rowHeight = 60;
        myTable.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
        
        xmpp.chatDelegate = self
        
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
    func CHATnewBuddyOffline(name: String) {
        onlineBuddies.removeObject(name)
        myTable.reloadData()
    }
    func CHATnewBuddyOnline(name: String) {
        onlineBuddies.append(name)
        myTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

