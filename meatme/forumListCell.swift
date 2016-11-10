//
//  forumCell.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/10.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class forumListCell: UITableViewCell {
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleContent: UILabel!
    @IBOutlet weak var articleAuthorName: UILabel!
    @IBOutlet weak var articleDate: UILabel!
    @IBOutlet weak var articleLoveNumber: UILabel!
    @IBOutlet weak var articleCommentNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
