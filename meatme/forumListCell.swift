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
    @IBOutlet weak var articleCategory: UILabel!
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
        //調整按下Cell後的背景顏色
        let view = UIView()
        view.backgroundColor = UIColor(red: 121.0/255.0, green: 180.0/255.0, blue: 146.0/255.0, alpha: 0.5)
        selectedBackgroundView = view
        

        // Configure the view for the selected state
    }

}
