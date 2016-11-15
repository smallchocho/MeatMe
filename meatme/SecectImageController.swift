//
//  SecectImageController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/14.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
class SecectImageController: UITableViewController {
    var getDataFromServer:JSON?
    var chooseImage = UIImage(named: "讀取中")
    @IBOutlet weak var chooseMeatImageView: UIImageView!
    @IBOutlet weak var firstMeatIgeView: UIImageView!
    @IBOutlet weak var firstMeatLabel: UILabel!
    @IBOutlet weak var secondMeatImageView: UIImageView!
    @IBOutlet weak var secondMeatLabel: UILabel!
    @IBOutlet weak var thirdMeatImageView: UIImageView!
    @IBOutlet weak var thirdMeatLabel: UILabel!
    var SecectImageData = [
        [
            "plantPicture":"多肉植物01",
            "plantName":"多肉01"
        ],
        [
            "plantPicture":"多肉植物02",
            "plantName":"多肉02"
        ],
        [
            "plantPicture":"多肉植物03",
            "plantName":"多肉03"
        ]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        inputData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension SecectImageController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1{
            performSegue(withIdentifier: "GoToForumList" , sender: nil)
        }
    }
    func inputData(){
        chooseMeatImageView.image = chooseImage
        let imageUrl1 = URL(string:getDataFromServer!["plants"][0]["plantPicture"].stringValue)
        firstMeatIgeView.sd_setImage(with: imageUrl1,placeholderImage: UIImage(named: "讀取中"))
        firstMeatLabel.text = getDataFromServer!["plants"][0]["plantDescription"].stringValue
        print(getDataFromServer!["plants"][0]["plantDescription"].stringValue)
        let imageUrl2 = URL(string:getDataFromServer!["plants"][1]["plantPicture"].stringValue)
        secondMeatImageView.sd_setImage(with: imageUrl2,placeholderImage: UIImage(named: "讀取中"))
        secondMeatLabel.text = getDataFromServer!["plants"][1]["plantDescription"].stringValue
        let imageUrl3 = URL(string:getDataFromServer!["plants"][2]["plantPicture"].stringValue)
        thirdMeatImageView.sd_setImage(with: imageUrl3,placeholderImage: UIImage(named: "讀取中"))
        thirdMeatLabel.text = getDataFromServer!["plants"][2]["plantDescription"].stringValue
    }
}
