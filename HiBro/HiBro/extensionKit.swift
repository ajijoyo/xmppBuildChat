//
//  extensionKit.swift
//  HiBro
//
//  Created by Dealjava on 12/3/15.
//  Copyright © 2015 dealjava. All rights reserved.
//

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    /** Remove first collection element that is equal to the given `object`:
     */
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

extension String  {
    /** generate method string to MD5
     */
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.destroy()
        return String(format: hash as String)
    }
}
