//
//  DiscoverViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/12/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation

class DiscoverViewController : ViewControllerWithAds {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        // testing
        containerView.frame = CGRectMake(containerView.frame.origin.x,containerView.frame.origin.y, containerView.frame.width, 800 )
        
    }
}
