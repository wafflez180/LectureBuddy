//
//  SignupViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FirebasePhoneAuthUI
import FBSDKLoginKit
import NVActivityIndicatorView

// Github FirebaseAuthUI README:
// [https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseAuthUI/README.md]

class SignupViewController: UIViewController, FUIAuthDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet var activityIndicator: NVActivityIndicatorVisew!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        facebookLoginButton.delegate = self
        configureFirebaseAuthentication()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        if isUserAuthenticated() {
            self.performSegue(withIdentifier: "authenticated", sender: self)
        }else{
            facebookLoginButton.isHidden = false
        }
    }
    
    // MARK: - SignupViewController
    
    func isUserAuthenticated() -> Bool {
        return (Auth.auth().currentUser != nil)
    }
    
    func configureFirebaseAuthentication(){
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth(),
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
            ]
        authUI?.providers = providers
    }
    
    func signinToFirebase(credential:AuthCredential){
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // User is signed in
            print("POOP")
            self.performSegue(withIdentifier: "authenticated", sender: self)
        }
    }
    
    // MARK: - FUIAuthDelegate
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print("SPAGGET!")
    }
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential:AuthCredential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        signinToFirebase(credential: credential)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    /*
     // MARK: - Navigation
     
     
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
