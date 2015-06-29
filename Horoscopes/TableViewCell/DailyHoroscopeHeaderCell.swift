//
//  DailyHoroscopeHeaderCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/18/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class DailyHoroscopeHeaderCell: UITableViewCell {
    
    @IBOutlet weak var chooseSignButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var collectTextLabel: UILabel!
    
    @IBOutlet weak var collectHoroscopeButton: UIButton!
    var signIndex = -1
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(signIndex : Int) {
//        println("setupHEADERCell DAILY")
        self.signIndex = signIndex
        if(signIndex != -1){ // -1 is not loaded
            var horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[signIndex] as Horoscope
            var image = UIImage(named: String(format:"%@_selected",horoscope.sign))
            chooseSignButton.setImage(image, forState: UIControlState.Normal)
            nameLabel.text = horoscope.sign
            dateLabel.text = Utilities.getSignDateString(horoscope.startDate, endDate: horoscope.endDate)
            
            if(Int32(signIndex) == XAppDelegate.userSettings.horoscopeSign){
                starImage.hidden = false
            }
            else {
                starImage.hidden = true
            }
        }
        collectHoroscopeButton.backgroundColor = UIColor.blueColor()
        
    }
    
    func updateAndAnimateCollectHoroscope(){
        var collectedHoro = CollectedHoroscope()
        
        var animationView = UIView(frame: CGRectMake(0, 0, Utilities.getScreenSize().width, Utilities.getScreenSize().height))
        animationView.backgroundColor = UIColor.blueColor()
        animationView.alpha = 1
        self.addSubview(animationView)
        //TODO: need to update animation
        UIView.animateWithDuration(1, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                animationView.alpha = 0
                animationView.center = CGPointMake(self.collectHoroscopeButton.center.x, self.collectHoroscopeButton.center.y+20)
                animationView.transform = CGAffineTransformMakeScale(0.2, 0.2);
            }) { (finish:Bool) -> Void in
                self.collectTextLabel.text = String(format:"%g",round(collectedHoro.getScore()*100))
                var newView = UIImageView(frame: self.collectHoroscopeButton.frame)
                newView.image = UIImage(named: "daily_archive_icon")
                self.addSubview(newView)
                newView.alpha = 0
                var newText = UILabel(frame: self.collectTextLabel.frame)
                newText.backgroundColor = UIColor.clearColor();
                newText.text = self.collectTextLabel.text;
                newText.font = self.collectTextLabel.font;
                newText.textAlignment = self.collectTextLabel.textAlignment;
                newText.textColor = UIColor(red:191.0/255,green:215.0/255,blue:48.0/255,alpha:1)
                self.addSubview(newText)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    newView.alpha = 1
                    newText.alpha = 1
                    }, completion: { (finished: Bool) -> Void in
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            newView.alpha = 0
                            newText.alpha = 0
                        }, completion: { (finished: Bool) -> Void in
                            newView.removeFromSuperview()
                            newText.removeFromSuperview()
                    })
                })
        }
    }
    
    // MARK: Button action
    @IBAction func collectButtonTapped(sender: AnyObject) {
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            let collectHoroscopesTableVC = storyboard.instantiateViewControllerWithIdentifier("CollectHoroscopesTableVC") as! CollectHoroscopesTableVC
        parentVC.navigationController?.pushViewController(collectHoroscopesTableVC, animated: true)
    }
}