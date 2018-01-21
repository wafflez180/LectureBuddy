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

class NewRecordingViewController: UIViewController, SpeechRecognitionManagerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var counterAndDateLabel: UILabel!
    @IBOutlet var restartingRecognitionView: RestartingRecognitionView!
    @IBOutlet var audioWaveView: AudioWaveView!
    
    @IBOutlet var stopAndSaveRecordingHeightConstraint: NSLayoutConstraint!
    @IBOutlet var followSpeechButtonHeightConstraint: NSLayoutConstraint!
    
    var isFollowingSpeech = true
    var hasEditedTitleField = false
    let speechRecognitionManager: SpeechRecognitionManager = .init(isDebugging: true)
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDismissKeyboardTapGesture()
        
        scrollView.delegate = self
        titleTextField.delegate = self
        speechRecognitionManager.delegate = self
        
        setupUI()
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
    
    func setupUI(){
        followSpeechButtonHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        //topScrollGradientView.layer.insertSublayer(ColorManager.getWhiteGradient(reversed: false, view: topScrollGradientView), at: 0)
        //topScrollGradientView.backgroundColor = .red
        
        restartingRecognitionView.setupView()
        setInitialTexts()
    }

    func setInitialTexts(){
        self.textView.text = "\"...\""
        setDateCounterLabel(numWords: 0)
    }
    
    func setDateCounterLabel(numWords:Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let dateText = dateFormatter.string(from: Date())
        
        self.counterAndDateLabel.text = String(numWords) + " words • " + dateText
    }
    
    func setTextViewText(transcription:String){
        var attributedTextViewText:NSMutableAttributedString = .init(string: transcription)

        let defaultStyle = Style.default {
            $0.lineSpacing = 1.20
            $0.font = FontAttribute.system(size: textView.font!.pointSize)
        }

        attributedTextViewText = attributedTextViewText.set(style: defaultStyle)
        
        // Get the range of each sentence that contains a keyword and highlight them.
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
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        let isTextOverflowing: Bool = self.scrollView.bounds.size.height < self.scrollView.contentSize.height
        if isFollowingSpeech && isTextOverflowing {
            self.scrollView.scrollToBottom(animated: true)
        }
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
    
    func showFollowSpeechButton(){
        followSpeechButtonHeightConstraint.constant = stopAndSaveRecordingHeightConstraint.constant
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissFollowSpeechButton(){
        followSpeechButtonHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - ScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isFollowingSpeech = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        showFollowSpeechButton()
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if hasEditedTitleField == false {
            
            self.titleTextField.selectAll(nil)
            
            hasEditedTitleField = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.dismissKeyboard()
        
        return false
    }
    
    // MARK: - SpeechRecognitionManagerDelegate
    
    func recognizedSpeech(fullTranscription: String) {
        setTextViewText(transcription: fullTranscription)
        
        let wordList = fullTranscription.split(separator: " ")
        setDateCounterLabel(numWords: wordList.count)
    }
    
    func didBeginCheckingForCancellation() {
        if isFollowingSpeech {
            scrollView.scrollToBottom(animated: true)
        }
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
    
    @IBAction func didPressStopRecordingButton(_ sender: Any) {
        speechRecognitionManager.stopRecognition()
        audioWaveView.stopListening()
        
        //let saveRecordingPopupView = SaveRecordingPopupView(initialTitle: titleTextField.text!)
        //saveRecordingPopupView.present(viewController: self)
        
        //self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didPressFollowSpeechButton(_ sender: Any) {
        isFollowingSpeech = true
        dismissFollowSpeechButton()
        scrollView.scrollToBottom(animated: true)
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
