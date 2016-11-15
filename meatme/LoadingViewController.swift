//
//  LoadingViewController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/14.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var loadingLabel: UILabel!
    var loadingLabelIsHidden = true

    @IBOutlet weak var kkdada: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingLabel.isHidden = loadingLabelIsHidden
        kkdada.setImage(UIImage(named: "多肉植物02"), for: UIControlState.normal)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
