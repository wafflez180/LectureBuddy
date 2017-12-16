//
//  SubjectTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class SubjectTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet var newRecordingView: UIView!
    @IBOutlet var newRecordingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    
    let hiddenYVal:CGFloat = -135.0
    var parentTableView:UITableView!
    var subjectName:String!
    var indexPath:IndexPath!
    var scrollPrevOffset:CGPoint = CGPoint.init()
    var hasSetInitialScrollOffset:Bool = false

    // MARK - UITableViewCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - SubjectTableViewCell
    
    func configureCell(subjectName:String, indexPath:IndexPath, isExpanded: Bool, parent:UITableView){
        self.subjectName = subjectName
        self.indexPath = indexPath
        parentTableView = parent
        
        // TO DO: FIX GLITCH WHEN REPETEADLY TAPPING SUBJECT HEADER BUTTONS
        // Hide the new recording cell trigger
        self.newRecordingViewWidthConstraint.constant = 0.0
        self.updateConstraints()
        self.layoutIfNeeded()

        setInitialCollectionScrollOffset()
        if isExpanded {
            animateShow()
        }
    }
    
    // By default the collectionView starts at the leftmost cell, set scroll to the right so user can swipe leftwards (for UI/UX)
    func setInitialCollectionScrollOffset(){
        DispatchQueue.main.async {
            // Scrolls to last item
            let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
            let lastItemIndex = IndexPath.init(item: item, section: 0)
            self.collectionView.scrollToItem(at: lastItemIndex, at: .right, animated: false)
            
            self.hasSetInitialScrollOffset = true
        }
    }
    
    func setupCollectionView(){
        let nib = UINib(nibName: "RecordingCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "recordingCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.masksToBounds = true
    }
    
    // MARK: - Collection View Collapse/Expand UI
    
    func animateShow(){
        // Begin higher from the hidden y position
        var newFrame = self.frame
        newFrame.origin.y = hiddenYVal
        UIView.performWithoutAnimation {
            self.frame = newFrame
            self.layoutIfNeeded()
        }
        // Descend downards to the resting y position
        newFrame.origin.y = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.parentTableView.reloadRows(at: [self.indexPath], with: .automatic)
            self.frame = newFrame
        })
    }
    
    func animateHide(){
        // Begin from resting y position
        var newFrame = self.frame
        // Ascend upwards to the hidden y position
        newFrame.origin.y = hiddenYVal
        let indexToReload = self.parentTableView.indexPath(for: self)!
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.parentTableView.reloadRows(at: [self.indexPath], with: .automatic)
            self.frame = newFrame
        })
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recordingCell", for: indexPath) as! RecordingCollectionViewCell
        
        return cell
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("PPOOOOOOPP")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("HAHH")
        //isScrollingLeftwards = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasSetInitialScrollOffset {
            //print(scrollView.contentOffset.x)
            //print(scrollPrevOffset.x)
            // If scrolling (bouncing) past the content in the scrollView
            let rightTriggerPadding:CGFloat = 10.0
            let fullScrollWidth:CGFloat = (scrollView.contentSize.width - scrollView.frame.size.width)
            let isScrollingLeftwards = (scrollPrevOffset.x > scrollView.contentOffset.x)
            if (scrollView.contentOffset.x >= (fullScrollWidth - rightTriggerPadding) && newRecordingViewWidthConstraint.constant == 0) && isScrollingLeftwards == false {
                //print("AH")
                // TO DO: bring the recording trigger cell
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                    scrollView.setContentOffset(CGPoint(x: fullScrollWidth+50, y: scrollView.contentOffset.y), animated: true)
                    self.newRecordingViewWidthConstraint.constant = 50
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }, completion: { finished in
                    scrollView.isScrollEnabled = true
                })
            }
            if isScrollingLeftwards && newRecordingViewWidthConstraint.constant == 50 {
                // User scrolling leftwards
                // TO DO: collapse new recording trigger cell
                //print("Hide")
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                    self.newRecordingViewWidthConstraint.constant = 0
                    self.updateConstraints()
                    self.layoutIfNeeded()
                })
            }
            // When scrolling is 1 off, update prevOffset
            if abs(scrollPrevOffset.x - scrollView.contentOffset.x) > 1 {
                scrollPrevOffset = scrollView.contentOffset
            }
        }
    }
    
    // func s
    
    // MARK: - UICollectionViewDelegate protocol
    /*
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     let generator = UIImpactFeedbackGenerator(style: .light)
     generator.impactOccurred()
     
     // handle tap events
     print("You selected cell #\(indexPath.item)!")
     let defaults = UserDefaults.standard
     var savedTitlesArray = defaults.stringArray(forKey: "SavedRapTitles") ?? [String]()
     var savedRapsArray = defaults.stringArray(forKey: "SavedRapBars") ?? [String]()
     
     print("Saved Titles Array: "+savedTitlesArray[indexPath.row])
     print("Saved Raps Array: "+savedRapsArray[indexPath.row])
     
     self.segueToSavedRapVC(rapBars: savedRapsArray[indexPath.row], rhymes: [], view: collectionView.cellForItem(at: indexPath)!, savedIndex: indexPath.row)
     }*/
    //    @IBAction func longPressedHeader(_ sender: Any) {
    //        delegate?.longPressedToDeleteSubject(subjectDocID: subjectDocID)
    //    }
}
