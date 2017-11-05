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
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
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
            self.saveUserToFireStore(user: user!)
            self.performSegue(withIdentifier: "authenticated", sender: self)
        }
    }
    
    func saveUserToFireStore(user:User){
        checkIfUserExists(userId: user.uid) { userExists in
            if !userExists {
                let defaultStore = Firestore.firestore()
                
                defaultStore.collection("Users").document(user.uid).setData([
                    "displayName": user.displayName ?? "",
                    "email": user.email ?? "",
                    "phoneNumber": user.phoneNumber ?? "",
                    "photoURL": user.photoURL?.absoluteString ?? "",
                    "id": user.uid
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("User Document added with ID: \(user.uid)")
                    }
                }
            }
        }
    }
    
    func checkIfUserExists(userId:String, completionHandler: @escaping (Bool) -> Void) {
        let defaultStore = Firestore.firestore()
        defaultStore.collection("Users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var userExists = false
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if document.documentID == userId {
                            print("Found existing User with ID: \(userId)")
                            userExists = true
                        }
                    }
                }
                completionHandler(userExists)
            }
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
}
