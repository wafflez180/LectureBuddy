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

class NewRecordingViewController: UIViewController, SpeechRecognitionManagerDelegate {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var counterAndDateLabel: UILabel!
    @IBOutlet var restartingRecognitionView: RestartingRecognitionView!
    @IBOutlet var audioWaveView: AudioWaveView!
    
    let speechRecognitionManager: SpeechRecognitionManager = .init(isDebugging: true)
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognitionManager.delegate = self
        restartingRecognitionView.setupView()
        setInitialTexts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        speechRecognitionManager.startRecognition()
        audioWaveView.startListening(updateTimeInterval: 0.1, speechRecogManager: speechRecognitionManager)
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
        var attributedTextViewText:NSMutableAttributedString = .init(string: transcription)

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
        
        self.textView.attributedText = "\"".set(style: defaultStyle) + attributedTextViewText + "...\"".set(style: defaultStyle)
        self.textView.sizeToFit()
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
        
        //print(rangesOfKeywordSentences.count)
        
        return rangesOfKeywordSentences
    }
    
    // MARK: - SpeechRecognitionManagerDelegate
    
    func recognizedSpeech(bestTranscription: String) {
        setTextViewText(transcription: bestTranscription)
        
        let wordList = bestTranscription.split(separator: " ")
        setDateCounterLabel(numWords: wordList.count)
    }
    
    func checkedIfRecognitionFinishedCancelling(secondsWaiting: Int) {
        restartingRecognitionView.show(withSecondsWaiting: secondsWaiting)
        //print("\(secondsWaiting)s waiting for cancellation to complete.")
    }
    
    func restartedRecognition(){
        restartingRecognitionView.animateOut()
        // TODO: Remove the 'Sorry for the inconvience' banner 
    }

    // MARK: - Actions
    
    @IBAction func didPressStopRecording(_ sender: Any) {
        speechRecognitionManager.stopRecognition()
        audioWaveView.stopListening()
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
