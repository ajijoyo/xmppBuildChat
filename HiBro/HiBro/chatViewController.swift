//
//  chatViewController.swift
//  HiBro
//
//  Created by Dealjava on 12/2/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

import UIKit
import Foundation

class chatViewController: UIViewController ,xmppMessageDelegate ,UITableViewDelegate,UITableViewDataSource , UITextFieldDelegate{
    @IBOutlet weak var msgTextField : UITextField!
    @IBOutlet weak var myTable : UITableView!
    
    internal var toChatName = ""
    
    let xmpp = xmppClientAppDelegate.sharedInstance
    
    private var chatM : [AnyObject] = [] {
        didSet{
            self.myTable.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        msgTextField.delegate = self
        
        xmpp.messageDelegate = self
        Log.D(toChatName)
        myTable.estimatedRowHeight = 20
        myTable.rowHeight = UITableViewAutomaticDimension;
        
        let hidekeyTap = UITapGestureRecognizer(target: self, action: "hidekey")
        myTable.addGestureRecognizer(hidekeyTap)
    }
    
    func hidekey(){
        msgTextField.resignFirstResponder()
    }
    
    //MARK: - uitextfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: uitableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatM.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.frame = cell.contentView.bounds
        cell.textLabel?.numberOfLines = 0
        
        if let dic = chatM[indexPath.row] as? [String : String] {
            cell.textLabel?.text = dic["msg"]
            if dic["sender"] == xmpp.xmppStream?.myJID.user {
                cell.textLabel?.textAlignment = NSTextAlignment.Left
            }else{
                cell.textLabel?.textAlignment = NSTextAlignment.Right
            }
        }

        return cell
    }
    
    @IBAction func sendBttnListener(){
        if let notNull = msgTextField.text {
            sendMessage(notNull)
        }else{
            Log.D("Kosong")
        }
    }
    
    
    func sendMessage(msg : String){
        let body = DDXMLElement(name: "body")
        body.setStringValue(msg)
        
        let message = DDXMLElement(name: "message")
        message.addAttributeWithName("type", stringValue: "chat")
        message.addAttributeWithName("to", stringValue: toChatName)
        message.addChild(body)
        
        xmpp.xmppStream?.sendElement(message)
        msgTextField.text = ""
        
        chatM.append(["msg":msg,"sender":xmpp.xmppStream!.myJID.user])
    }
    
    func MESSAGEnewMessageReceive(message: AnyObject) {
        chatM.append(message)
    }
    //MARK: - memory managment
    deinit{
        chatM.removeAll()
        toChatName = ""
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
