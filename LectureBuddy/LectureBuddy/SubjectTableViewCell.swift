//
//  SubjectTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class SubjectTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var headerView: UIView!
    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var headerButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var parentTableView:UITableView!
    var subjectName:String!
    let expandedCollectionViewHeight:CGFloat = 180
    let highlightedColor:UIColor = UIColor.init(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    
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
        // Start the scroll from right to left
        collectionView?.contentOffset = CGPoint.init(x: collectionView.contentSize.width-collectionView.frame.size.width, y: (collectionView?.contentOffset.y)!)
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
        
        // Reload cell row and highlight headerView with grey color
        UIView.animate(withDuration: 0.2, animations: {
            self.parentTableView.reloadRows(at: [self.parentTableView.indexPath(for: self)!], with: UITableViewRowAnimation.automatic)
            self.headerView.backgroundColor = self.highlightedColor
        }) { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                self.headerView.backgroundColor = UIColor.white
            })
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
