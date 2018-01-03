//
//  NewRecordingViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/16/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Speech

class NewRecordingViewController: UIViewController {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var counterAndDateLabel: UILabel!
    
    // SFSpeechRecognizerDelegate
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialTexts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.recordAndRecognizeSpeech()
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NewRecordingViewController

    func setInitialTexts(){
        self.textView.text = "\"...\""
        setDateCounterLabel(numWords: 0)
    }
    
    func setDateCounterLabel(numWords:Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let dateText = dateFormatter.string(from: Date())
        
        self.counterAndDateLabel.text = String(numWords) + "w • " + dateText
    }
    
    func setTextViewText(transcription:String){
        self.textView.attributedText = "\"...\""
    }
        
    func updateTexts(transcription:String){
        self.textView.text = "\"" + transcription + "...\""
        
        let wordList = transcription.split(separator: " ")
        setDateCounterLabel(numWords: wordList.count)
    }
    
    // MARK: - Actions
    
    @IBAction func didPressStopRecording(_ sender: Any) {
        endRecording()
        self.dismiss(animated: true, completion: nil)
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

// Check out the link to understand this SFSpeechRecognizerDelegate code : https://medium.com/ios-os-x-development/speech-recognition-with-swift-in-ios-10-50d5f4e59c48
extension NewRecordingViewController : SFSpeechRecognizerDelegate {
    
    func recordAndRecognizeSpeech(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
        }
        
        // TODO: - Handle these errors with a UIAlert view
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            print("A recognizer is not supported for the current locale")
            return
        }
        if !myRecognizer.isAvailable {
            // A recogniszer is not avaliable right now
            print("A recogniszer is not avaliable right now")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if result != nil {
                if let result = result {
                    
                    let bestString = result.bestTranscription.formattedString
                    self.updateTexts(transcription: bestString)
                    
                } else if let error = error {
                    print(error)
                }
            }
        })
    }
    
    func endRecording(){
        request.endAudio()
        audioEngine.stop()
        
        let node = audioEngine.inputNode
        node.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
    }
}
