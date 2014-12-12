//
//  Listing.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

class Listing {
    let children: [Thing]
    let after: String
    let before: String
    let modhash: String
    
    class func empty() -> Listing {
        return Listing(children: [], after: "", before: "", modhash: "")
    }
    
    init (children: [Thing], after: String, before: String, modhash: String) {
        self.children = children
        self.after = after
        self.before = before
        self.modhash = modhash
    }
    
    var count: Int {
        return children.count
    }
    
    subscript(index: Int) -> Thing {
        return children[index]
    }
}
