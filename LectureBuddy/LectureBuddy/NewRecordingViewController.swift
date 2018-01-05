//
//  NewRecordingViewController.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/16/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import Speech
import SwiftRichString

class NewRecordingViewController: UIViewController {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var counterAndDateLabel: UILabel!
    
    // SFSpeechRecognizerDelegate
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    let audioDurationLimit = 60.0
    var isRecordingSpeech = false
    var resetSpeechRecognitionTimer: Timer = Timer()
    
    var repeatRecognitionCounter = 0
    var repeatedRecognitionCancelledCheckCounter = 1

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialTexts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startSpeechRecognitionResetTimer()
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
        var attributedTextViewText:NSMutableAttributedString = .init(string: "\"" + transcription + "...\"")

        let defaultStyle = Style.default {
            $0.lineSpacing = 1.20
            $0.font = FontAttribute.system(size: textView.font!.pointSize)
        }

        attributedTextViewText = attributedTextViewText.set(style: defaultStyle)
        
        // Get the sentences containing a keyword and highlight them.
        let highlightStyle = Style.default {
            $0.backColor = SRColor.init(hex: "F8E71C") // Yellow
            $0.lineSpacing = 1.20
            $0.font = FontAttribute.system(size: textView.font!.pointSize)
        }
        
        let keywordSentenceRanges = getKeywordSentenceRanges(transcription: transcription)

        for sentenceRange in keywordSentenceRanges {
            attributedTextViewText = attributedTextViewText.set(style: highlightStyle, range: sentenceRange)
        }
        
        self.textView.attributedText = attributedTextViewText
    }
    
    func getKeywordSentenceRanges(transcription:String) -> [Range<String.Index>] {
        let highlightingKeywords: [String] = DataManager.sharedInstance.highlightedKeywords
        let transcribedSentences = transcription.split(separator: ".")
        var sentencesWithKeyword:[String] = []
        
        // Go through each sentence and see if it contains a highlighting keyword.
        // If it does, put the sentence in an array.
        for sentence in transcribedSentences {
            for keyword:String in highlightingKeywords {
                if String(sentence).lowercased().contains(keyword.lowercased()) {
                    sentencesWithKeyword.append(String(sentence))
                    break
                }
            }
        }
        
        var rangesOfKeywordSentences:[Range<String.Index>] = []

        // Get the range of each keyword sentence
        for sentence in sentencesWithKeyword {
            rangesOfKeywordSentences.append(transcription.range(of: sentence)!)
        }
        
        print(rangesOfKeywordSentences.count)
        
        return rangesOfKeywordSentences
    }
        
    func updateTexts(transcription:String){
        setTextViewText(transcription: transcription)
        
        let wordList = transcription.split(separator: " ")
        setDateCounterLabel(numWords: wordList.count)
    }
    
    // MARK: - Actions
    
    @IBAction func didPressStopRecording(_ sender: Any) {
        endRecording()
        resetSpeechRecognitionTimer.invalidate()
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
    
    func startSpeechRecognitionResetTimer() {
        resetSpeechRecognitionTimer.invalidate()
        resetSpeechRecognitionTimer = Timer.scheduledTimer(timeInterval: audioDurationLimit, target: self, selector: #selector(resetSpeechRecognitionTask), userInfo: nil, repeats: false)
    }
    
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
        
        isRecordingSpeech = true
        
        print("isCancelled: \(String(describing: recognitionTask?.isCancelled))")
        print("isFinishing: \(String(describing: recognitionTask?.isFinishing))")
        print("state: \(String(describing: recognitionTask?.state.rawValue))")
        print("state completed: \(String(describing: SFSpeechRecognitionTaskState.completed.rawValue))")
        print("state canceling: \(String(describing: SFSpeechRecognitionTaskState.canceling.rawValue))")
        print("state finishing: \(String(describing: SFSpeechRecognitionTaskState.finishing.rawValue))")
        print("state running: \(String(describing: SFSpeechRecognitionTaskState.running.rawValue))")
        print("state starting: \(String(describing: SFSpeechRecognitionTaskState.starting.rawValue))")

        repeatRecognitionCounter+=1
        self.textView.text = String(describing: repeatRecognitionCounter)
        
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
    
    func recordSpeechAfterTaskIsFinishedCompleting(){
        //print("recordSpeechAfterTaskIsFinishedCompleting")
        //print("state: \(String(describing: recognitionTask?.state.rawValue))")
        if recognitionTask?.state == .completed {
            startSpeechRecognitionResetTimer()
            recordAndRecognizeSpeech()
            repeatedRecognitionCancelledCheckCounter = 1
        } else {
            print("\(repeatedRecognitionCancelledCheckCounter)s waiting for cancellation to complete.")
            repeatedRecognitionCancelledCheckCounter+=1
            // Call this method again till the task has completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.recordSpeechAfterTaskIsFinishedCompleting()
            })
        }
    }
    
    @objc func resetSpeechRecognitionTask() { // resetSpeechRecognitionTaskWithTimer ? Need to change the name of it maybe?
        if isRecordingSpeech {
            endRecording()
            recordSpeechAfterTaskIsFinishedCompleting()
        }
    }
}
