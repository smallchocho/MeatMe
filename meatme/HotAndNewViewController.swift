//
//  ViewController.swift
//  meatme
//
//  Created by Justin Huang on 2016/10/24.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class HotAndNewViewController: UIViewController {
    @IBOutlet weak var hotSite: UICollectionView!
    @IBOutlet weak var newSite: UICollectionView!
    var newSiteImage = ["多肉植物01","多肉植物02","多肉植物03","多肉植物01","多肉植物02","多肉植物03","多肉植物01","多肉植物02","多肉植物03"]
    override func viewDidLoad() {
        super.viewDidLoad()
        hotSite.delegate = self
        hotSite.dataSource = self
        newSite.delegate = self
        newSite.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension HotAndNewViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === hotSite {
            return 3
        }
        return newSiteImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === hotSite {
            return CGSize(width: self.view.bounds.width, height: self.view.bounds.height/2.45)
        }else{
            return CGSize(width: self.view.bounds.width/3, height: self.view.bounds.width/3)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === hotSite {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HotSite", for: indexPath) as! hotSiteCell
        cell.hotSiteName.setTitle("有肉Succulent&Gift", for:
            UIControlState.normal)
        cell.heartNuber.text = "87"
        cell.checkInNumber.text = "87"
        cell.siteImageView.image = UIImage(named: "有肉")
        return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewSite", for: indexPath) as! newSiteCell
            cell.siteImageView.image = UIImage(named: newSiteImage[indexPath.row])
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 0)
    }
}
