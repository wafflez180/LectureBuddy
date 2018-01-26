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
    
    var subjects:[Subject] = []
    var highlightedKeywords:[String] = []
    let defaultStore = Firestore.firestore()
    
    // MARK: - DataManager
    
    func loadSubjectsAndRecordings(completion: @escaping () -> Void) {
        self.loadSubjects {
            print("Loaded \(self.subjects.count) subjects")
            let numSubjectsToLoad = self.subjects.count
            var loadedCounter = 0
            
            for subject in self.subjects {
                self.loadRecordings(subjectDocId: subject.documentID, completion: { recordings in
                    subject.recordings = recordings
                    
                    print("\tLoaded \(recordings.count) \(subject.name) recordings")
                    loadedCounter+=1
                    
                    if loadedCounter == numSubjectsToLoad {
                        print("Completed loading subjects and recordings.")
                        completion()
                    }
                })
            }
        }
    }
    
    // MARK: - Recordings

    func saveNewRecording(subject: Subject, recording: Recording, success: @escaping () -> Void) {
        self.defaultStore.collection("Users").document((Auth.auth().currentUser?.uid)!).collection("subjects").document(subject.documentID).collection("recordings").addDocument(data: [
            "title" : recording.title,
            "text" : recording.text,
            "dateCreated" : Date()
        ]) { error in
            print("Saved \(recording.title) for \(subject.name)")
            success()
        }
    }
    
    func deleteRecording(recording: Recording, completionHandler: @escaping () -> Void) {
        self.defaultStore.collection("Users").document((currentUser?.uid)!).collection("subjects").document(recording.subjectDocumentId!).collection("recordings").document(recording.documentID!).delete { error in
            print("\(recording.title) recording has been successfully deleted")
            completionHandler()
        }
    }
    
    func loadRecordings(subjectDocId:String, completion: @escaping ([Recording]) -> Void) {
        let recordingsQuery = defaultStore.collection("Users").document((currentUser?.uid)!).collection("subjects").document(subjectDocId).collection("recordings").order(by: "dateCreated", descending: true)
        
        recordingsQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var recordings:[Recording] = []
                
                for doc in (querySnapshot?.documents)! {
                    recordings.append(Recording.init(document: doc, subjectDocId: subjectDocId))
                }
                
                completion(recordings)
            }
        }
    }

    // MARK: - Subjects
    
    func saveNewSubject(subjectName:String, success: @escaping () -> Void, subjectExistsError: @escaping () -> Void) {
        checkIfSubjectExists(subjectName: subjectName) { subjectExists in
            if subjectExists {
                print("Subject exists, returning error")
                subjectExistsError()
            }else{
                self.defaultStore.collection("Users").document((Auth.auth().currentUser?.uid)!).collection("subjects").document(subjectName).setData([
                    "name": subjectName,
                    "dateCreated": NSDate()
                ]) { error in
                    // To Do: Handle error (User can't add a new subject if the subject's name already exists)
                    self.loadSubjects(completion: {
                        success()
                    })
                }
            }
        }
    }
    
    func loadSubjects(completion: @escaping () -> Void) {
        let subjectsQuery = defaultStore.collection("Users").document((currentUser?.uid)!).collection("subjects").order(by: "dateCreated")

        subjectsQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.subjects = []
                
                for doc in (querySnapshot?.documents)! {
                    self.subjects.append(Subject.init(document: doc))
                }
                
                completion()
            }
        }
    }
    
    func checkIfSubjectExists(subjectName:String, completionHandler: @escaping (Bool) -> Void) {
        defaultStore.collection("Users").document((currentUser?.uid)!).collection("subjects").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completionHandler(false)
            } else {
                var subjectExists = false
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if document.documentID == subjectName {
                            print("Found existing Subject with ID: \(subjectName)")
                            subjectExists = true
                        }
                    }
                }
                completionHandler(subjectExists)
            }
        }
    }
    
    func deleteSubject(subject: Subject, completionHandler: @escaping () -> Void) {
        
        for recording in subject.recordings {
            self.deleteRecording(recording: recording, completionHandler: {})
        }
        
        self.defaultStore.collection("Users").document((currentUser?.uid)!).collection("subjects").document(subject.documentID).delete { error in
            print("\(subject.name) subject has been successfully deleted")
            completionHandler()
        }
    }
    
    // MARK: - Keywords
    
    func deleteKeyword(index:Int) {
        let removedKeyword = highlightedKeywords.remove(at: index)
        self.defaultStore.collection("Users").document((currentUser?.uid)!).updateData([
            "highlightKeywords": highlightedKeywords,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("'\(removedKeyword)' keyword has been successfully deleted")
                }
        }
    }
    
    func addKeyword(keyword:String) {
        highlightedKeywords.append(keyword)
        self.defaultStore.collection("Users").document((currentUser?.uid)!).updateData([
            "highlightKeywords": highlightedKeywords,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("'\(keyword)' keyword has been successfully added")
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
    func saveUserToFireStore(user:User, completionHandler: @escaping () -> Void){
        checkIfUserExists(userId: user.uid) { userExists in
            if !userExists {
                self.defaultStore.collection("Users").document(user.uid).setData([
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
                    completionHandler()
                }
            } else {
                print("User already exists, doing nothing.")
                completionHandler()
            }
        }
    }
    
    func checkIfUserExists(userId:String, completionHandler: @escaping (Bool) -> Void) {
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
            self.saveUserToFireStore(user: user!, completionHandler: {
                self.getUserData(success: {
                    success()
                }, error: {
                    error()
                })
            })
        }
    }
    
    func getUserData(success: @escaping () -> Void, error: @escaping () -> Void){
        defaultStore.collection("Users").document((currentUser?.uid)!).addSnapshotListener({ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(error)")
                error()
            } else {
                if let highlightKwds = querySnapshot?.data()["highlightKeywords"] {
                    self.highlightedKeywords = highlightKwds as! [String]
                }
                print("Keywords: \(self.highlightedKeywords)")
                success()
            }
        })
    }
    
    // MARK: - FUIAuthDelegate
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // Does nothing, needed for sign in/up authentication
    }
}
