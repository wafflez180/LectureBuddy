//
//  AudioWaveView.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 1/6/18.
//  Copyright © 2018 Arthur De Araujo. All rights reserved.
//

import UIKit

class AudioWaveView: WaveformView {

    var levelList:[CGFloat] = []
    let levelListLimit = 2
    let maximumLevel:CGFloat = 1.0
    
    var updateAudioWaveTimer:Timer?
    var speechRecognitionManager:SpeechRecognitionManager?
    
    public func startListening(updateTimeInterval:CGFloat, speechRecogManager: SpeechRecognitionManager){
        self.speechRecognitionManager = speechRecogManager
        self.updateAudioWaveTimer = Timer.scheduledTimer(timeInterval: 0.1 , target: self, selector: #selector(updateAudioWave), userInfo: nil, repeats: true)
    }
    
    public func stopListening(){
        self.updateAudioWaveTimer?.invalidate()
        self.updateAudioWaveTimer = nil
    }
    
    @objc func updateAudioWave(){
        //print("speechRecognitionManager.volumeFloat: \(speechRecognitionManager.volumeFloat)")
        let increasedVolumeVal = (25 * (speechRecognitionManager?.volumeFloat)!)
        //print("Increased Volume: \(increasedVolumeVal)")
        self.updateWithAveragingLevel(increasedVolumeVal)
    }

    // UpdatesTheLevel using the calculated average of the last 2 (Whatever the levelListLimit Is) levels passed in
    public func updateWithAveragingLevel(_ level: CGFloat) {
        // Limit the levels so it doesn't get too large
        var volumeLevel = level
        if (volumeLevel > maximumLevel){
            volumeLevel = maximumLevel
        }
        
        // Add the newest level and remove the oldest
        levelList.append(volumeLevel)
        if levelList.count > levelListLimit {
            levelList.removeFirst()
        }
        
        self.updateWithLevel(getAverageLevel())
    }
    
    func getAverageLevel() -> CGFloat {
        var averageLevel:CGFloat = 0.0
        
        for elem in levelList {
            averageLevel+=elem
        }
        
        averageLevel /= CGFloat(levelList.count)
        //print("Average Level: \(averageLevel)")
        return averageLevel
    }
}
