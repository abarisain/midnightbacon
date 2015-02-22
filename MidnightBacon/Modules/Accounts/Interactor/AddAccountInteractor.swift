//
//  AddAccountInteractor.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/25/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class AddAccountInteractor {
    var gateway: Gateway!
    var secureStore: SecureStore!
    var addAccountPromise: Promise<Bool>!
    
    init() { }
    
    func addCredential(credential: NSURLCredential, completion: () -> ()) {
        let request = LoginRequest(
            username: credential.user!,
            password: credential.password!,
            rememberPastSession: true,
            apiType: .JSON
        )
        addAccountPromise = gateway.performRequest(request, session: nil).then(self, { (interactor, session) -> Result<Session> in
            return Result(interactor.store(credential, session))
        }).then(self, { (session) -> Result<Bool> in
            completion()
            return Result(true)
        })
    }
    
    func store(credential: NSURLCredential, _ session: Session) -> Promise<Session> {
        return secureStore.save(credential, session).then(self, { (context, success) -> Result<Session> in
            return Result(session)
        }).recover(self, { (context, error) -> Result<Session> in
            println(error)
            return Result(session)
        })
    }
}
