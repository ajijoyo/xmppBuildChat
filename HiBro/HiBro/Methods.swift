//
//  Methods.swift
//  HiBro
//
//  Created by Dealjava on 12/1/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

import UIKit

class Methods: NSObject {
    
    /**
     * Get Current ViewController
     */
    class func currentVC() -> UIViewController{
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController!
        
        while ((topController!.presentedViewController) != nil) {
            topController = topController!.presentedViewController;
        }
        return topController!
    }
}


extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    /** Remove first collection element that is equal to the given `object`:
    */
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

/**
 * LOG for debug mode
 */
class Log {
    /**
     * Just Log when is debug!!!
     */
    class func D(msg : Any) {
        #if DEBUG
            print(msg)
        #endif
    }
}