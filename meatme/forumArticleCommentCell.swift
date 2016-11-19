//
//  forumArticleCommentCell.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/11.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class forumArticleCommentCell: UITableViewCell {
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var commentAuthorName: UILabel!
    @IBOutlet weak var commentAuthorImage: UIImageView!
    @IBOutlet weak var commentDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
