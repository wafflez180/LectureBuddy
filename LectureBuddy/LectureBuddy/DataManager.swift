//
//  DataManager.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/5/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FirebasePhoneAuthUI

class DataManager: NSObject, FUIAuthDelegate {
    
    // MARK: Shared Instance
    
    static let sharedInstance = DataManager()
    
    // MARK: Local Variables
    
    var currentUser:User? {
        return Auth.auth().currentUser
    }
    
    // MARK: DataManager

    func saveNewSubject(subjectName:String, completion: @escaping () -> Void) {
        let defaultStore = Firestore.firestore()
        defaultStore.collection("Users").document((Auth.auth().currentUser?.uid)!).collection("subjects").document(subjectName).setData([
            "name": subjectName,
            "dateCreated": NSDate()
        ]) { error in
            completion()
        }
    }
    
    func getSubjectDocuments(completion: @escaping ([DocumentSnapshot]) -> Void) {
        var subjectDocuments:[DocumentSnapshot] = []
        let defaultStore = Firestore.firestore()
        defaultStore.collection("Users").document((currentUser?.uid)!).collection("subjects").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                subjectDocuments = (querySnapshot?.documents)!
                completion(subjectDocuments)
            }
        }
    }
    
    // MARK: - Sign In/Up
    
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
    
    // Saves user to Firestore if the user exits, else does nothing
    func saveUserToFireStore(user:User){
        checkIfUserExists(userId: user.uid) { userExists in
            if !userExists {
                let defaultStore = Firestore.firestore()
                
                defaultStore.collection("Users").document(user.uid).setData([
                    "displayName": user.displayName ?? "",
                    "email": user.email ?? "",
                    "phoneNumber": user.phoneNumber ?? "",
                    "photoURL": user.photoURL?.absoluteString ?? "",
                    "id": user.uid,
                    "highlightKeywords": ["Important", "Remember", "Understand"],
                    "dateCreated": NSDate()
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("User Document added with ID: \(user.uid)")
                    }
                }
            } else {
                print("User already exists, doing nothing.")
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
    
    func signinToFirebase(credential:AuthCredential, success: @escaping () -> Void, error: @escaping () -> Void){
        Auth.auth().signIn(with: credential) { (user, err) in
            if let err = err {
                print(err.localizedDescription)
                error()
                return
            }
            // User is signed in
            DataManager.sharedInstance.saveUserToFireStore(user: user!)
            success()
        }
    }
    
    // MARK: - FUIAuthDelegate
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // Does nothing, needed for sign in/up authentication
    }
}
