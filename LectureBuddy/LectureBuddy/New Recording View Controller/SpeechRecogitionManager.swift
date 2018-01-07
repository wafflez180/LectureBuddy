//
//  SpeechRecogitionManager.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/5/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import Foundation
import Speech

protocol SpeechRecognitionManagerDelegate {
    func recognizedSpeech(bestTranscription:String)
    func checkedIfRecognitionFinishedCancelling(secondsWaiting:Int)
    func restartedRecognition()
}

// Check out the link to understand this SFSpeechRecognizerDelegate code : https://medium.com/ios-os-x-development/speech-recognition-with-swift-in-ios-10-50d5f4e59c48
class SpeechRecognitionManager : NSObject, SFSpeechRecognizerDelegate {
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let applesAudioDurationLimit = 60.0
    //private var isRecordingSpeech = false
    private var resetSpeechRecognitionTimer: Timer = Timer()
    
    var repeatRecognitionCounter = 0     // Incremented everytime the recognition gets restarted
    private var repeatedRecognitionCancelledCheckCounter = 1     // Incremented every second the recognition is in the process of cancelling and restarting
    
    var delegate: SpeechRecognitionManagerDelegate?
    private var isDebugging:Bool = false
    var volumeFloat:CGFloat = 0.0
    
    init(isDebugging: Bool) {
        self.isDebugging = isDebugging
    }
    
    func startRecognition(){
        self.startSpeechRecognitionResetTimer()
        self.recordAndRecognizeSpeech()
    }
    
    func stopRecognition(){
        self.endRecording()
        resetSpeechRecognitionTimer.invalidate()
    }
    
    private func startSpeechRecognitionResetTimer() {
        resetSpeechRecognitionTimer.invalidate()
        resetSpeechRecognitionTimer = Timer.scheduledTimer(timeInterval: applesAudioDurationLimit, target: self, selector: #selector(resetSpeechRecognitionTask), userInfo: nil, repeats: false)
    }
    
    // Check out this link to understand how this works: https://miguelsaldana.me/2017/03/18/how-to-create-a-volume-meter-in-swift-3/
    func updateVolume(withBuffer:AVAudioPCMBuffer){
        let buffer = withBuffer
        
        let dataptrptr = buffer.floatChannelData!           //Get buffer of floats
        let dataptr = dataptrptr.pointee
        let datum = dataptr[Int(buffer.frameLength) - 1]    //Get a single float to read
        
        //store the float on the variable
        self.volumeFloat = CGFloat(fabs((datum)))
    }
    
    private func recordAndRecognizeSpeech(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.updateVolume(withBuffer: buffer)
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("SpeechRecognitionManager: \(error)")
        }
        
        // TODO: - Handle these errors with a UIAlert view
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            print("SpeechRecognitionManager: A recognizer is not supported for the current locale")
            return
        }
        if !myRecognizer.isAvailable {
            // A recogniszer is not avaliable right now
            print("SpeechRecognitionManager: A recogniszer is not avaliable right now")
            return
        }
                
        if isDebugging {
            print("SpeechRecognitionManager: isCancelled: \(String(describing: recognitionTask?.isCancelled))")
            print("SpeechRecognitionManager: isFinishing: \(String(describing: recognitionTask?.isFinishing))")
            print("SpeechRecognitionManager: state: \(String(describing: recognitionTask?.state.rawValue))")
            print("SpeechRecognitionManager: state when completed: \(String(describing: SFSpeechRecognitionTaskState.completed.rawValue))")
            print("SpeechRecognitionManager: state when canceling: \(String(describing: SFSpeechRecognitionTaskState.canceling.rawValue))")
            print("SpeechRecognitionManager: state when finishing: \(String(describing: SFSpeechRecognitionTaskState.finishing.rawValue))")
            print("SpeechRecognitionManager: state when running: \(String(describing: SFSpeechRecognitionTaskState.running.rawValue))")
            print("SpeechRecognitionManager: state when starting: \(String(describing: SFSpeechRecognitionTaskState.starting.rawValue))")
        }
        
        repeatRecognitionCounter+=1
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if result != nil {
                if let result = result {
                    
                    let bestString = result.bestTranscription.formattedString
                    self.delegate?.recognizedSpeech(bestTranscription: bestString)
                    
                } else if let error = error {
                    print(error)
                }
            }
        })
    }
    
    private func endRecording(){
        request.endAudio()
        audioEngine.stop()
        
        let node = audioEngine.inputNode
        node.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
    }
    
    // Calls itself repeatedly until the recognition task is completed and then it begins a new recogition task
    private func recordSpeechAfterTaskIsFinishedCompleting(){
        if recognitionTask?.state == .completed {
            startSpeechRecognitionResetTimer()
            recordAndRecognizeSpeech()
            repeatedRecognitionCancelledCheckCounter = 1
            self.delegate?.restartedRecognition()
        } else {
            if isDebugging {
                print("SpeechRecognitionManager: \(repeatedRecognitionCancelledCheckCounter)s waiting for cancellation to complete.")
                print("SpeechRecognitionManager: taskState: \(String(describing: recognitionTask?.state.rawValue)).")
            }
            
            self.delegate?.checkedIfRecognitionFinishedCancelling(secondsWaiting: repeatedRecognitionCancelledCheckCounter)
            repeatedRecognitionCancelledCheckCounter+=1
            
            // Call this method again till the task has completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.recordSpeechAfterTaskIsFinishedCompleting()
            })
        }
    }
    
    // Called by the resetSpeechRecognitionTimer when apple's audio limit ( 1 min ) is exceeded it's time
    @objc private func resetSpeechRecognitionTask() { // resetSpeechRecognitionTaskWithTimer ? Need to change the name of it maybe?
            endRecording()
            recordSpeechAfterTaskIsFinishedCompleting()
    }
}
