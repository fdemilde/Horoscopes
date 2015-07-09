//
//  PostCellNode.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class PostCellNode: ASCellNode {
    var userPost: UserPost!
    
    init!(userPost: UserPost) {
        super.init()
        self.userPost = userPost
    }
}