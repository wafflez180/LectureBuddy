//
//  SubjectTableViewCell.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit

class SubjectTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var headerButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK - UITableViewCell

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - SubjectTableViewCell

    func setupCollectionView(){
        let nib = UINib(nibName: "RecordingCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "recordingCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
    }
    
}
