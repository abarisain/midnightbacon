//
//  OAuthRefreshTokenRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 1/7/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

class OAuthRefreshTokenRequest : APIRequest {
    let mapperFactory: RedditFactory
    let grantType: OAuthGrantType
    let clientID: String
    let accessToken: OAuthAccessToken

    init(mapperFactory: RedditFactory, clientID: String, accessToken: OAuthAccessToken) {
        self.mapperFactory = mapperFactory
        self.grantType = .RefreshToken
        self.clientID = clientID
        self.accessToken = accessToken
    }
    
    typealias ResponseType = OAuthAccessToken
    
    func parse(response: URLResponse) -> Outcome<OAuthAccessToken, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<OAuthAccessToken, Error> in
            return mapperFactory.accessTokenMapper().map(json)
        }
    }
    
    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        let request = prototype.POST(
            "/api/v1/access_token",
            parameters: [
                "grant_type": grantType.rawValue,
                "refresh_token": accessToken.refreshToken,
            ]
        )
        request.basicAuthorization(username: clientID, password: "")
        return request
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return nil
    }
}
