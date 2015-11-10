//
//  NoPostView.swift
//  Horoscopes
//
//  Created by Dang Doan on 11/10/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import UIKit

class NoPostView: UIView {
    
    var storyButton: UIButton!
    var feelButton: UIButton!
    var fortuneButton: UIButton!
    var mindButton: UIButton!
    var storyLabel: UILabel!
    var feelLabel: UILabel!
    var fortuneLabel: UILabel!
    var mindLabel: UILabel!
    let POST_BUTTON_SIZE = UIImage(named: "newsfeed_post_story")!.size
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        storyButton = UIButton()
        storyButton.setImage(UIImage(named: "newsfeed_post_story"), forState: .Normal)
        storyButton.addTarget(self, action: "storyButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(storyButton)
        
        feelButton = UIButton()
        feelButton.setImage(UIImage(named: "newsfeed_post_feel"), forState: .Normal)
        feelButton.addTarget(self, action: "feelButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(feelButton)
        
        fortuneButton = UIButton()
        fortuneButton.setImage(UIImage(named: "newsfeed_post_fortune"), forState: .Normal)
        fortuneButton.addTarget(self, action: "fortuneButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(fortuneButton)
        
        mindButton = UIButton()
        mindButton.setImage(UIImage(named: "newsfeed_post_mind"), forState: .Normal)
        mindButton.addTarget(self, action: "mindButtonTapped:", forControlEvents: .TouchUpInside)
        addSubview(mindButton)
        
        storyLabel = UILabel()
        configureLabel(storyLabel, text: "Share your story")
        feelLabel = UILabel()
        configureLabel(feelLabel, text: "How do you feel today?")
        fortuneLabel = UILabel()
        configureLabel(fortuneLabel, text: "Write a fortune")
        mindLabel = UILabel()
        configureLabel(mindLabel, text: "What's on your mind?")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        storyButton.frame = getPostButtonFrame(0)
        feelButton.frame = getPostButtonFrame(1)
        fortuneButton.frame = getPostButtonFrame(2)
        mindButton.frame = getPostButtonFrame(3)
        
        configureOriginOf(storyLabel, basedOn: storyButton)
        configureOriginOf(feelLabel, basedOn: feelButton)
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
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        } else {
            label.font = UIFont.systemFontOfSize(14)
        }
        addSubview(label)
        label.sizeToFit()
    }
    
    func setTextColor(color: UIColor) {
        storyLabel.textColor = color
        feelLabel.textColor = color
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
    
    func storyButtonTapped(sender: UIButton) {
        print("button \(sender) tapped")
    }
    
    func feelButtonTapped(sender: UIButton) {
        print("button \(sender) tapped")
    }
    
    func fortuneButtonTapped(sender: UIButton) {
        print("button \(sender) tapped")
    }
    
    func mindButtonTapped(sender: UIButton) {
        print("button \(sender) tapped")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
