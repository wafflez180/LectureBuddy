//
//  SubjectTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class SubjectTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let hiddenYVal:CGFloat = -135.0
    var parentTableView:UITableView!
    var parentVC:HomeTableViewController!
    var subjectName:String!
    var indexPath:IndexPath!
    
    // extension SubjectTableViewCell: UIScrollViewDelegate
    var scrollPrevOffset:CGPoint = CGPoint.init()
    var hasSetInitialScrollOffset:Bool = false
    var beganInteraction = false
    var progress:CGFloat = 0.0
    let progressNeededToFinishTransition:CGFloat = 0.125 // 12.5% of interaction progress needed to finish the transition, else cancel transition

    // MARK - UITableViewCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - SubjectTableViewCell
    
    func configureCell(subjectName:String, indexPath:IndexPath, isExpanded: Bool, parentVC:HomeTableViewController, isRefreshingTable:Bool){
        self.subjectName = subjectName
        self.indexPath = indexPath
        self.parentTableView = parentVC.tableView
        self.parentVC = parentVC
        
        // TO DO: FIX GLITCH WHEN REPETEADLY TAPPING SUBJECT HEADER BUTTONS
        // Hide the new recording cell trigger
        self.updateConstraints()
        self.layoutIfNeeded()

        if hasSetInitialScrollOffset == false {
            setInitialCollectionScrollOffset()
        }
        if isExpanded && isRefreshingTable == false && collectionView.isDragging == false {
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
        collectionView.register(UINib(nibName: "RecordingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "recordingCell")
        collectionView.register(UINib(nibName: "NewRecordingCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "newRecordingCell")
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
        return 7 // For the new recording cell
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "recordingCell", for: indexPath) as! RecordingCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //if (kind == UICollectionElementKindSectionFooter) {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "newRecordingCell", for: indexPath)
    }
    
    
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

// UIScrollViewDelegate mainly being used for the interaction controller
// which transitions from the HomeTableViewController to a NewRecordingViewController
extension SubjectTableViewCell: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if progress >= progressNeededToFinishTransition {
            print("Finished Progress: \(progress)")
            print("Finished Interaction.")
            parentVC.interactionController?.finish()
            beganInteraction = false
            parentVC.interactionController = nil
        }
    }
    
    func cancelInteraction(){
        print("Cancelled Interaction")
        self.parentVC.interactionController?.cancel()
        beganInteraction = false
        parentVC.interactionController = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasSetInitialScrollOffset {
            let scrollViewOffsetDiff = (scrollView.contentSize.width - scrollView.frame.width) - scrollView.contentOffset.x
            print(scrollViewOffsetDiff)
            //print("Content Offset X: \(scrollView.contentOffset.x)")

            progress = (scrollViewOffsetDiff / UIScreen.main.bounds.width) * -1
            
            // If the user is dragging leftwards, to the point where
            // if the user lets go, the scrollView will bounce back
            if scrollViewOffsetDiff < 0.0 {
                // Begin Interaction
                if beganInteraction == false && scrollView.isDragging {
                    parentVC.interactionController = UIPercentDrivenInteractiveTransition()
                    
                    // Set the selectedRecordingCell to the collectionView's visible footer
                    HomeTableViewController.selectedRecordingCell = collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionFooter)[0] as! NewRecordingCollectionViewCell
                    
                    // Set up the view controller to transition to, start the transition and begin interaction/animation
                    var newRecordingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewRecordingViewCont") as! NewRecordingViewController
                    newRecordingVC.transitioningDelegate = parentVC
                    parentVC.present(newRecordingVC, animated: true, completion: nil)
                    beganInteraction = true
                }else{
                    // Update transition when progress/scrollViewOffset changes
                    print("Progress: \(progress)")
                    parentVC.interactionController?.update(progress)
                }
            // If the user scrolled and started an interaction then scrolled back, cancel the interaction
            } else if beganInteraction {
                cancelInteraction()
            }
        }
    }
}

