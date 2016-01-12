//
//  NoPostView.swift
//  Horoscopes
//
//  Created by Dang Doan on 11/10/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import UIKit

class PostButtonsView: UIView {
    
    var adviceButton: UIButton!
    var howButton: UIButton!
    var fortuneButton: UIButton!
    var mindButton: UIButton!
    var adviceLabel: UILabel!
    var howLabel: UILabel!
    var fortuneLabel: UILabel!
    var mindLabel: UILabel!
    var POST_BUTTON_SIZE = UIImage(named: "newsfeed_post_advice")!.size
    var hostViewController: UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adviceButton = UIButton()
        adviceButton.setImage(UIImage(named: "newsfeed_post_advice"), forState: .Normal)
        adviceButton.addTarget(self, action: "adviceButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(adviceButton)
        
        howButton = UIButton()
        howButton.setImage(UIImage(named: "newsfeed_post_horoscope"), forState: .Normal)
        howButton.addTarget(self, action: "feelButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(howButton)
        
        fortuneButton = UIButton()
        fortuneButton.setImage(UIImage(named: "newsfeed_post_fortune"), forState: .Normal)
        fortuneButton.addTarget(self, action: "fortuneButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(fortuneButton)
        
        mindButton = UIButton()
        mindButton.setImage(UIImage(named: "newsfeed_post_mind"), forState: .Normal)
        mindButton.addTarget(self, action: "mindButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(mindButton)
        
        adviceLabel = UILabel()
        configureLabel(adviceLabel, text: postTypes[NewsfeedType.ShareAdvice]!.1)
        
        howLabel = UILabel()
        configureLabel(howLabel, text: postTypes[NewsfeedType.HowHoroscope]!.1)
        
        fortuneLabel = UILabel()
        configureLabel(fortuneLabel, text: postTypes[NewsfeedType.Fortune]!.1)
        
        mindLabel = UILabel()
        configureLabel(mindLabel, text: postTypes[NewsfeedType.OnYourMind]!.1)
    }
    
    convenience init(frame: CGRect, forceChangeButtonSize : Bool) {
        self.init(frame: frame)
        if(forceChangeButtonSize){
            if(DeviceType.IS_IPHONE_4_OR_LESS){
                POST_BUTTON_SIZE.width = POST_BUTTON_SIZE.width * 3 / 4
                POST_BUTTON_SIZE.height = POST_BUTTON_SIZE.height * 3 / 4
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        howButton.frame = getPostButtonFrame(0)
        adviceButton.frame = getPostButtonFrame(1)
        fortuneButton.frame = getPostButtonFrame(3)
        mindButton.frame = getPostButtonFrame(2)
        
        
        configureOriginOf(howLabel, basedOn: howButton)
        configureOriginOf(adviceLabel, basedOn: adviceButton)
        configureOriginOf(fortuneLabel, basedOn: fortuneButton)
        configureOriginOf(mindLabel, basedOn: mindButton)
    }
    
    private func configureOriginOf(label: UILabel, basedOn button: UIButton) {
        label.frame.origin = CGPoint(x: button.frame.origin.x + (POST_BUTTON_SIZE.width - label.frame.width)/2, y: button.frame.origin.y + button.frame.height + 6)
    }
    
    private func configureLabel(label: UILabel, text: String) {
        label.text = text
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.frame.size.width = POST_BUTTON_SIZE.width
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            let size = UIScreen.mainScreen().bounds.size
            if size.height == 480 {
                if #available(iOS 8.2, *) {
                    label.font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight)
                } else {
                    label.font = UIFont.systemFontOfSize(11)
                }
            } else {
                if #available(iOS 8.2, *) {
                    label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
                } else {
                    label.font = UIFont.systemFontOfSize(14)
                }
            }
        }
        addSubview(label)
        label.sizeToFit()
    }
    
    func setTextColor(color: UIColor) {
        adviceLabel.textColor = color
        howLabel.textColor = color
        fortuneLabel.textColor = color
        mindLabel.textColor = color
    }
    
    func getPostButtonFrame(buttonIndex : Int) -> CGRect {
        let screenWidth = frame.width
        let screenHeight = frame.height
        
        // there are 4 buttons divided into 2 rows, 2 buttons for each row
        // col 0 : col 1
        // Button0 - Button1 : row 0
        // Button2 - Button3 : row 1
        let rowNumber = buttonIndex / 2
        let colNumber = buttonIndex % 2
        let paddingWidth = (screenWidth - (POST_BUTTON_SIZE.width * 2)) / 3
        let buttonPositionX = paddingWidth * CGFloat(colNumber + 1) + (CGFloat(colNumber) * POST_BUTTON_SIZE.width)
        let paddingHeight = (screenHeight - (POST_BUTTON_SIZE.height * 2)) / 3
        let buttonPositionY = paddingHeight * CGFloat(rowNumber + 1) + (CGFloat(rowNumber) * POST_BUTTON_SIZE.height)
        return CGRectMake(buttonPositionX, buttonPositionY, POST_BUTTON_SIZE.width, POST_BUTTON_SIZE.height)
    }
    
    private func configureViewController(type: String, placeholder: String) {
        let controller = hostViewController.storyboard?.instantiateViewControllerWithIdentifier("DetailPostViewController") as! DetailPostViewController
        controller.type = type
        controller.placeholder = placeholder
        hostViewController.presentViewController(controller, animated: true, completion: nil)
        if(hostViewController.isKindOfClass(CustomTabBarController)){
            let newsfeedViewController = hostViewController as! CustomTabBarController
           newsfeedViewController.overlayFadeout()
        }
    }
    
    private func buttonTapped(type: String, placeholder: String) {
        let label = "type = \(type)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.postSelect, label: label)
        configureViewController(type, placeholder: placeholder)
    }
    
    func adviceButtonTapped(sender: UIButton) {
        buttonTapped("shareadvice", placeholder: postTypes[NewsfeedType.ShareAdvice]!.1)
    }
    
    func feelButtonTapped(sender: UIButton) {
        buttonTapped("howhoroscope", placeholder: postTypes[NewsfeedType.HowHoroscope]!.1)
    }
    
    func fortuneButtonTapped(sender: UIButton) {
        buttonTapped("fortune", placeholder: postTypes[NewsfeedType.Fortune]!.1)
    }
    
    func mindButtonTapped(sender: UIButton) {
        buttonTapped("onyourmind", placeholder: postTypes[NewsfeedType.OnYourMind]!.1)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
