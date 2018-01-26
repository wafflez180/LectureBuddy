//
//  RecordingTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 12/22/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import SwiftRichString

class RecordingTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var containerView: UIView!
    
    // MARK: - UITableViewCell

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - RecordingTableViewCell

    func setup(recording: Recording) {
        titleLabel.text = recording.title
        setTextViewText(transcription: recording.text)
        
        let numWords = recording.text.split(separator: " ").count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let dateText = dateFormatter.string(from: recording.dateCreated)
        
        self.dateLabel.text = String(numWords) + " words • " + dateText
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
        
        self.textView.attributedText = "\"".set(style: defaultStyle) + attributedTextViewText + "\"".set(style: defaultStyle)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
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
        
        return rangesOfKeywordSentences
    }
}
