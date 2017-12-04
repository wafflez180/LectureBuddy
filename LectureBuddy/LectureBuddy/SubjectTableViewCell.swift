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
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var headerButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var parentTableView:UITableView!
    var subjectName:String!
    let expandedCollectionViewHeight:CGFloat = 180
    let highlightedColor:UIColor = UIColor.init(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
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
    
    func configureCell(subjectName:String, parent:UITableView){
        self.subjectName = subjectName
        headerTitle.text = subjectName
        parentTableView = parent
        
        setSubjectSelectionFromCache(subjectName: subjectName)
        setInitialCollectionScrollOffset()
        
        // Hide the new recording cell trigger
        UIView.performWithoutAnimation {
            self.newRecordingViewWidthConstraint.constant = 0.0
            self.updateConstraints()
            self.layoutIfNeeded()
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
    
    func setSubjectSelectionFromCache(subjectName:String){
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        if let isSubjectSelected = isSubjectExpandedDict?[subjectName] {
            headerButton.isSelected = isSubjectSelected
        }
    }
    
    func cacheSubjectSelection(selected:Bool){
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        if isSubjectExpandedDict == nil {
            let dict:[String:Bool] = [subjectName: headerButton.isSelected]
            UserDefaults.standard.set(dict, forKey: "isSubjectSelectedDict")
        }else{
            isSubjectExpandedDict![subjectName] = headerButton.isSelected
            UserDefaults.standard.set(isSubjectExpandedDict!, forKey: "isSubjectSelectedDict")
        }
        print(isSubjectExpandedDict)
    }
    
    // MARK - Actions
    
    @IBAction func highlightedHeaderButton(_ sender: Any) {
        // Sets headerButton bg to greyish color
        headerView.backgroundColor = highlightedColor
    }
    
    @IBAction func pressedHeaderButton(_ sender: Any) {
        headerButton.isSelected = !headerButton.isSelected
        
        cacheSubjectSelection(selected: headerButton.isSelected)
        self.bringSubview(toFront: headerButton)
        self.sendSubview(toBack: collectionView)
        self.sendSubview(toBack: self)
        // Reload cell row and highlight headerView with grey color
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.parentTableView.reloadRows(at: [self.parentTableView.indexPath(for: self)!], with: UITableViewRowAnimation.fade)
                self.headerView.backgroundColor = self.highlightedColor
                
                var newFrame = self.collectionView.frame
                if self.headerButton.isSelected == false {
                    newFrame.origin.y = -135.0
                }
                self.collectionView.frame = newFrame
            }) { finished in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.headerView.backgroundColor = UIColor.white
                })
                
                var newFrame = self.collectionView.frame
                if self.headerButton.isSelected {
                    newFrame.origin.y = -135
                }else{
                    newFrame.origin.y = 75.0
                }
                self.collectionView.frame = newFrame
            }
        }
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
