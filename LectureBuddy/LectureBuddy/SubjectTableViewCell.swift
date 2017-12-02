//
//  SubjectTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class SubjectTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var headerButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var parentTableView:UITableView!
    var subjectName:String!
    let expandedCollectionViewHeight = 180
    
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
    }
    
    func setupCollectionView(){
        let nib = UINib(nibName: "RecordingCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "recordingCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.masksToBounds = true
        // To Do: - set 6 to the num of recording elems - 1 (219 == the width of a recordingCell)
        collectionView?.contentOffset = CGPoint.init(x: 6*219, y: (collectionView?.contentOffset.y)!)
    }
    
    func setSubjectSelectionFromCache(subjectName:String){
        var isSubjectExpandedDict = UserDefaults.standard.value(forKey: "isSubjectSelectedDict") as? [String:Bool]
        if let isSubjectSelected = isSubjectExpandedDict?[subjectName] {
            headerButton.isSelected = isSubjectSelected
            setCellHeight(subjectSelected: isSubjectSelected)
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
        setCellHeight(subjectSelected: headerButton.isSelected)
        print(isSubjectExpandedDict)
    }
    
    func setCellHeight(subjectSelected:Bool){
        print("change")
        parentTableView.beginUpdates()
        if subjectSelected {
            collectionViewHeightConstraint.constant = 180
        } else {
            collectionViewHeightConstraint.constant = 0
        }
        parentTableView.endUpdates()
        self.updateConstraints()
        self.layoutIfNeeded()
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

    // MARK - Actions
    
    @IBAction func pressedHeaderButton(_ sender: Any) {
        headerButton.isSelected = !headerButton.isSelected
        cacheSubjectSelection(selected: headerButton.isSelected)
    }
        //    @IBAction func longPressedHeader(_ sender: Any) {
//        delegate?.longPressedToDeleteSubject(subjectDocID: subjectDocID)
//    }
}
