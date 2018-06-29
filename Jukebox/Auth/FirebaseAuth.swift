//
//  FirebaseAuth.swift
//  Jukebox
//
//  Created by Philipp on 29.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import FirebaseAuth
import Alamofire

extension Auth {
    func signIn(with session: SPTSession?, completion: @escaping (User?, Error?) -> Void) {
        guard let session = session else { completion(nil, NSError(domain: "Custom Auth", code: 401, userInfo: [NSLocalizedDescriptionKey : "No Session found"])); return}
        let headers: HTTPHeaders = [ "Authorization": "Bearer \(session.accessToken!)" ]
        Alamofire.request(URL(string: "https://jkbx-swapify.herokuapp.com/authenticate")!, method: .get, headers: headers).responseString { (response) in
            if let error = response.error { completion(nil, error); return }
            let JWToken = response.value!
            self.signIn(withCustomToken: JWToken, completion: { (response, error) in
                if let error = error { completion(nil, error); return }
                if let response = response {
                    completion(response.user, nil)
                } else {completion(nil, NSError(domain: "Custom Auth", code: 404, userInfo: [NSLocalizedDescriptionKey : "An error occured"]));}
                return
            })
        }
    }
    
    func signOut(completion: (_: Error?)->Void){
        do {try Auth.auth().signOut()}
        catch let error as NSError { completion(error); return}
        SPTAudioStreamingController.sharedInstance().logout()
        SPTAuth.defaultInstance().session = nil
        UserDefaults.standard.removeObject(forKey: SpotifyConfig.sessionKey)
        completion(nil)
    }
}
