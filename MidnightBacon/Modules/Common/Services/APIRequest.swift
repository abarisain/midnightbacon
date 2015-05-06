//
//  RequestBuilder.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

protocol APIRequest {
    typealias ResponseType
    func parse(response: URLResponse) -> Outcome<ResponseType, Error>
    func build() -> NSMutableURLRequest
}

struct APIRequestOf<T> : APIRequest {
    let parseWrapper: (URLResponse) -> Outcome<T, Error>
    let buildWrapper: () -> NSMutableURLRequest
    
    init<R: APIRequest where R.ResponseType == T>(_ instance: R) {
        parseWrapper = { instance.parse($0) }
        buildWrapper = { instance.build() }
    }
    
    func parse(response: URLResponse) -> Outcome<T, Error> {
        return parseWrapper(response)
    }
    
    func build() -> NSMutableURLRequest {
        return buildWrapper()
    }
}