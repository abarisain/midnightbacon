//
//  CommentsRequest.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import ModestProposal
import FranticApparatus
import Common

enum CommentsSort : String {
    case Confidence = "confience"
    case Top = "top"
    case New = "new"
    case Hot = "hot"
    case Controversial = "controversial"
    case Old = "old"
    case Random = "random"
    case QA = "qa"
}

/*
Get the comment tree for a given Link article.
If supplied, comment is the ID36 of a comment in the comment tree for article. This comment will be the (highlighted) focal point of the returned view and context will be the number of parents shown.
depth is the maximum depth of subtrees in the thread.
limit is the maximum number of comments to return.
See also: /api/morechildren and /api/comment.
*/
class CommentsRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    let article: String // ID36 of a link
    let comment: String? // (optional) ID36 of a comment
    let context: Int? // an integer between 0 and 8
    let depth: Int? // (optional) an integer
    let limit: Int? // (optional) an integer
    let showedits: Bool?
    let showmore: Bool?
    let sort: CommentsSort? // One of (confidence, top, new, hot, controversial, old, random, qa)
    
    convenience init(mapperFactory: RedditFactory, prototype: NSURLRequest, article: Link) {
        self.init(mapperFactory: mapperFactory, prototype: prototype, article: article.id, comment: nil, context: nil, depth: nil, limit: nil, showedits: nil, showmore: nil, sort: nil)
    }
    
    init(mapperFactory: RedditFactory, prototype: NSURLRequest, article: String, comment: String?, context: Int?, depth: Int?, limit: Int?, showedits: Bool?, showmore: Bool?, sort: CommentsSort?) {
        assert(count(article) > 0, "Invalid article")
        self.mapperFactory = mapperFactory
        self.prototype = prototype
        self.article = article
        self.comment = comment
        self.context = context
        self.depth = depth
        self.limit = limit
        self.showedits = showedits
        self.showmore = showmore
        self.sort = sort
    }
    
    typealias ResponseType = (Listing, [Thing])
    
    func parse(response: URLResponse) -> Outcome<(Listing, [Thing]), Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<(Listing, [Thing]), Error> in
            if !json.isArray {
                return Outcome(UnexpectedJSONError())
            }
            
            if json.count != 2 {
                return Outcome(UnexpectedJSONError())
            }
            
            let linkListingOutcome = mapperFactory.listingMapper().map(json[0])
            let commentListingOutcome = mapperFactory.listingMapper().map(json[1])

            switch (linkListingOutcome, commentListingOutcome) {
            case (.Success(let linkResult), .Success(let listingResult)):
                return Outcome((linkResult.unwrap, self.flattenComments(listingResult.unwrap)))
            case (.Success(let linkResult), .Failure(let listingReason)):
                return Outcome(listingReason.unwrap)
            case (.Failure(let linkReason), .Success(let listingResult)):
                return Outcome(linkReason.unwrap)
            case (.Failure(let linkReason), .Failure(let listingReason)):
                return Outcome(linkReason.unwrap)
            }
        }
    }
    
    func flattenComments(listing: Listing) -> [Thing] {
        var thingStack = [[Thing]]()
        var indexStack = [Int]()
        var outputThings = [Thing]()
        var inputThings = listing.children
        var index = 0
        
        thingStack.append(inputThings)
        indexStack.append(index)
        
        while thingStack.count > 0 {
            inputThings = thingStack.removeLast()
            index = indexStack.removeLast()

            while index < inputThings.count {
                let inputThing = inputThings[index]
                ++index
                
                if let comment = inputThing as? Comment {
                    comment.depth = thingStack.count
                    outputThings.append(comment)
                    
                    if let replies = comment.replies {
                        thingStack.append(inputThings)
                        indexStack.append(index)
                        inputThings = replies.children
                        index = 0
                    } else {
                    }
                } else if let more = inputThing as? More {
                    more.depth = thingStack.count
                    outputThings.append(more)
                }
            }
        }
        
        return outputThings
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 7)
        parameters["comment"] = comment
        parameters["context"] = String(context)
        parameters["depth"] = String(depth)
        parameters["limit"] = String(limit)
        parameters["showedits"] = String(showedits)
        parameters["showmore"] = String(showmore)
        parameters["sort"] = sort?.rawValue
        return prototype.GET("/comments/\(article).json", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return .Read
    }
}
