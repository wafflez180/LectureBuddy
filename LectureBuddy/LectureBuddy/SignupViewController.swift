//
//  SignupViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import NVActivityIndicatorView

// Github FirebaseAuthUI README:
// [https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseAuthUI/README.md]

class SignupViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        facebookLoginButton.delegate = self
        DataManager.sharedInstance.configureFirebaseAuthentication()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        if DataManager.sharedInstance.isUserAuthenticated() {
            self.performSegue(withIdentifier: "authenticated", sender: self)
        }else{
            facebookLoginButton.isHidden = false
        }
    }
    
    // MARK: - SignupViewController
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential:AuthCredential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        DataManager.sharedInstance.signinToFirebase(credential: credential, success: {
            self.performSegue(withIdentifier: "authenticated", sender: self)
        }) {
            // Error, TODO: Do Something
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Do Nothing
    }
}
