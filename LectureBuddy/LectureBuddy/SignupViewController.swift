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

class SignupViewController: UIViewController {
    
    @IBOutlet var facebookLoginButton: UIButton!
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        DataManager.sharedInstance.configureFirebaseAuthentication()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        if DataManager.sharedInstance.isUserAuthenticated() {
            DataManager.sharedInstance.loadSubjectsAndRecordings {
                DataManager.sharedInstance.getUserData(success: {
                    self.segueToHomePage()
                }, error: {
                    
                    print("AHHH ERROR")
                }
                
                )
            }
        }else{
            self.activityIndicator.stopAnimating()
            facebookLoginButton.isHidden = false
        }
    }
    
    // MARK: - SignupViewController
    
    func segueToHomePage(){
        self.activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: "authenticated", sender: self)
    }
    
    // MARK: - Actions
    
    @IBAction func pressedFacebookLogInButton(_ sender: Any) {
        let loginManager:FBSDKLoginManager = FBSDKLoginManager.init()
        let permissions = ["public_profile", "email"]
        
        activityIndicator.startAnimating()
        loginManager.logIn(withReadPermissions: permissions, from: self) { result, error in
            if (error != nil) {
                print("Process error")
            } else if (result?.isCancelled)! {
                print("Cancelled")
            } else {
                print("Logged in")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                DataManager.sharedInstance.signinToFirebase(credential: credential, success: {
                    DataManager.sharedInstance.loadSubjectsAndRecordings(completion: {
                        self.segueToHomePage()
                    })
                }) {
                    // Error, TODO: Do Something
                }
            }
        }
    }
}
