//
//  FollowingFeedsCollectionView.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class FollowingFeedsCollectionView : UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    private let reuseIdentifier = "FollowingCollectionCell"
    var userPostArray = [UserPost]()
    
    override func awakeFromNib() {
        println("FollowingFeedsCollectionView awakeFromNib awakeFromNib")
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
//        self.registerClass(FollowingCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.dataSource = self
        self.delegate = self
    }
    
    // MARK: populate date
    func populateData(postArray: [UserPost]){
        userPostArray = postArray
        println("populateData populateData = \(userPostArray.count)")
        self.reloadData()
    }
    
    // MARK: UICollectionView datasource & delegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("userPostArray.count userPostArray.count = \(userPostArray.count)")
        return userPostArray.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FollowingCollectionCell
        println("cellForItemAtIndexPath cellForItemAtIndexPath = \(userPostArray.count)")
        cell.populateData(userPostArray[indexPath.item])
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(80, 80);
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
//    {
//        return UIEdgeInsetsMake(5, 5, 5, 5); //top,left,bottom,right
//    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Collection View select == \(indexPath.row)")
    }
}