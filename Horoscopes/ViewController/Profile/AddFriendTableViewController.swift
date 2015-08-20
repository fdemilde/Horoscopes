//
//  AddFriendTableViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/27/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class AddFriendTableViewController : TableViewControllerWithAds, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var searchIcon: UIImageView!
    var searchFBHolderLabel: UILabel!
    var searchTextfield: UITextField!
    
    @IBOutlet weak var tableViewReference: UITableView! // to keep a reference to the tableview
    var viewReference: UIView! // a reference to the new background view
    
    
    var friendList = [UserProfile]()
    var followingUsers = [UserProfile]()
    var parentVC : ProfileViewController!
    var followingCheckArray = [Bool]()
    let MAX_SEARCH_LENGTH = 40 as CGFloat
    let BANNER_HEIGHT = 50 as CGFloat
    let TABBAR_HEIGHT = 49 as CGFloat
    let TITLE_AND_SEARCH_HEIGHT = 87 as CGFloat
    let SEARCH_ICON_PADDING = 5 as CGFloat
    let SEARCH_ICON_SIZE = 15 as CGFloat
    let SEARCH_TEXTFIELD_PADDING_LEFT = 15 as CGFloat
    let SEARCH_TEXTFIELD_PADDING_RIGHT = 20 as CGFloat
    /*
    override setter for view and tableView so that we have a viewReference
    to support drag interaction while disable tableView when the sidebar is shown
    */
    override var view : UIView! {
        get {
            return self.viewReference
        }
        set {
            super.view = newValue
        }
    }
    
    override var tableView : UITableView! {
        get {
            return self.tableViewReference
        }
        set {
            super.tableView = newValue
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.instantiateViewReferenceAndTableView()
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        self.setupViewTitleAndBackButton()
        self.setupSearchBar()
        self.loadFriendList()
    }
    
    func instantiateViewReferenceAndTableView(){
        // instantiate the new self.view, similar to the tableview
        self.viewReference = UIView(frame: self.tableViewReference.frame)
        self.viewReference.backgroundColor = self.tableViewReference.backgroundColor
        self.viewReference.autoresizingMask = self.tableViewReference.autoresizingMask;
        // add it as a subview
        self.viewReference.addSubview(self.tableViewReference)
        
        // resize TableView, headerview
        self.tableHeaderView.frame = CGRectMake(0, 0, Utilities.getScreenSize().width,BANNER_HEIGHT + TITLE_AND_SEARCH_HEIGHT)
        
        self.tableViewReference.frame = CGRectMake(5, tableHeaderView.frame.height, Utilities.getScreenSize().width - 10, Utilities.getScreenSize().height - BANNER_HEIGHT - TABBAR_HEIGHT - TITLE_AND_SEARCH_HEIGHT)
        
        self.tableView.layer.cornerRadius = 3
        self.tableView.layer.masksToBounds = true
    }
    
    func setupViewTitleAndBackButton(){
        var title = UILabel(frame: CGRectMake(0, BANNER_HEIGHT, Utilities.getScreenSize().width, 50))
        title.textAlignment = NSTextAlignment.Center
        title.text = "Friends to Follow"
        title.font = UIFont.systemFontOfSize(17)
        title.textColor = UIColor.whiteColor()
        self.view.addSubview(title)
        
        var backButton = UIButton(frame: CGRectMake(0, BANNER_HEIGHT, 50, 50))
        backButton.setImage(UIImage(named: "back_button"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        
        
    }
    
    func setupSearchBar(){ // create a searchbar inside Table Header View under the admob
        // Search Background
        var searchBg = UIView(frame: CGRectMake(20, 100, Utilities.getScreenSize().width - 40, 25))
        searchBg.backgroundColor = UIColor(red: 46/255.0, green: 52/255.0, blue: 77/255.0, alpha: 1)
        searchBg.layer.cornerRadius = 25 / 2
        searchBg.layer.masksToBounds = true
        
        // Search FB Friend Label
        searchFBHolderLabel = UILabel()
        searchFBHolderLabel.text = "Search Facebook Friends"
        searchFBHolderLabel.font = UIFont.systemFontOfSize(14)
        searchFBHolderLabel.textColor = UIColor(red: 180/255.0, green: 180/255.0, blue: 186/229.0, alpha: 1)
        searchFBHolderLabel.sizeToFit()
        searchFBHolderLabel.frame = CGRectMake((searchBg.frame.width - searchFBHolderLabel.frame.width)/2 + SEARCH_ICON_PADDING + SEARCH_ICON_SIZE,(searchBg.frame.height - searchFBHolderLabel.frame.height)/2 , searchFBHolderLabel.frame.width, searchFBHolderLabel.frame.height) // +18px for search icon and icon padding
        searchBg.addSubview(searchFBHolderLabel)
        
        // Search Icon
        searchIcon = UIImageView(frame: CGRectMake(searchFBHolderLabel.frame.origin.x - (SEARCH_ICON_PADDING + SEARCH_ICON_SIZE), (searchBg.frame.height - SEARCH_ICON_SIZE)/2, SEARCH_ICON_SIZE, SEARCH_ICON_SIZE))
        searchIcon.image = UIImage(named: "search_icon")
        searchBg.addSubview(searchIcon)
        
        // search Textfield
        searchTextfield = UITextField()
        searchTextfield.frame = CGRectMake(SEARCH_TEXTFIELD_PADDING_LEFT, 0, searchBg.frame.width - SEARCH_TEXTFIELD_PADDING_RIGHT, searchBg.frame.height)
        searchTextfield.textColor = UIColor.whiteColor()
        searchTextfield.font = UIFont.systemFontOfSize(14)
        searchTextfield.delegate = self
        searchTextfield.clearButtonMode = UITextFieldViewMode.WhileEditing
        searchBg.addSubview(searchTextfield)
        self.view.addSubview(searchBg)
    }
    
    // MARK: Setting and load data
    func loadFriendList(){
        Utilities.showHUD(viewToShow: self.view)
        XAppDelegate.socialManager.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                println("retrieveFriendList error == \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    Utilities.hideHUD(viewToHide: self.view)
                    self.friendList = result
                    // after get friend list, should loop through the list and check if user is following or not
                    
                    for user in self.friendList{
                        self.checkAndAddToFollowingArray(user.uid)
                    }
                    self.tableView.reloadData()
                    
                })
            }
        }
        
    }
    
    // after get friend list, should loop through the list and check if user is following or not
    func checkAndAddToFollowingArray(uid : Int){
        for user in DataStore.sharedInstance.followingUsers{
            if(user.uid == uid){
                followingCheckArray.append(true)
                return
            }
        }
        followingCheckArray.append(false)
    }
    
    // MARK: Table view delegate & data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return friendList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("AddFriendTableCell", forIndexPath: indexPath) as! AddFriendTableCell
        // need to update profile view controller when tap on follow button, we store its reference
        cell.setupCell(friendList[indexPath.row], isFollowing: followingCheckArray[indexPath.row], profileVC: parentVC)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        println("select === \(indexPath.row)")
    }
    
    
    // MARK: Button action
    
    func backButtonTapped(){
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    // MARK: Textfield delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.searchIcon.hidden = true
        self.searchFBHolderLabel.hidden = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.searchIcon.hidden = false
        self.searchFBHolderLabel.hidden = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: gesture regconizer
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if(touch.view.isDescendantOfView(tableView)){
            return false
        }
        
        return true
    }
    
    func dismissKeyboard(){
        searchTextfield.resignFirstResponder()
        searchTextfield.text = ""
        searchIcon.hidden = false
        searchFBHolderLabel.hidden = false
    }
}