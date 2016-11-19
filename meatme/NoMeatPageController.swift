//
//  NoMeatPageController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/15.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class NoMeatPageController: UITableViewController {
    var chooseImage = UIImage(named: "讀取中")
    var errorMessage = "有什麼事情出錯了喔"
    @IBOutlet weak var chooseMeatImageView: UIImageView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseMeatImageView.image = chooseImage
        self.errorMessageLabel.text = errorMessage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
