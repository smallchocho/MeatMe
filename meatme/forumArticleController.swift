//
//  forumArticleController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/11.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class forumArticleController: UIViewController {
    @IBOutlet weak var forumArticleTableView: UITableView!
    var forumArticleData:[String:String] = [
        "articleTitleId":"1",
        "articleTitle":"1111",
        "articleCategory":"11111",
        "articleContent":"11111111",
        "articleAuthorName":"111111",
        "articleAuthorImage":"多肉植物02",
        "articleImage":"多肉植物01",
        "articleDate":"111111",
        "articleLoveNumber":"11",
        "articleCommentNumber":"11"
    ]
    var forumArticleCommentData = [
        [
            "commentContent":"11111111",
            "commentAuthorName":"111111",
            "commentAuthorImage":"多肉植物02",
            "commentDate":"111111",
            ],
        [
            "commentContent":"2222222",
            "commentAuthorName":"222222",
            "commentAuthorImage":"多肉植物03",
            "commentDate":"222222",
            ],
        [
            "commentContent":"33333333",
            "commentAuthorName":"333333",
            "commentAuthorImage":"多肉植物01",
            "commentDate":"333333",
            ],
        [
            "commentContent":"4444444",
            "commentAuthorName":"4444444",
            "commentAuthorImage":"多肉植物02",
            "commentDate":"4444444",
            ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forumArticleTableView.delegate = self
        self.forumArticleTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension forumArticleController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forumArticleCommentData.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "forumArticleCell", for: indexPath) as! forumArticleCell
            cell.articleTitle.text = forumArticleData["articleTitle"]
            cell.articleContent.text = forumArticleData["articleContent"]
            cell.articleAuthorName.text = forumArticleData["articleAuthorName"]
            cell.articleAuthorImage.image = UIImage(named:forumArticleData["articleAuthorImage"]!)
            cell.articleImage.image = UIImage(named:forumArticleData["articleImage"]!)
            cell.articleDate.text = forumArticleData["articleDate"]
            cell.articleLoveNumber.text = forumArticleData["articleLoveNumber"]
            cell.articleCommentNumber.text = forumArticleData["articleCommentNumber"]
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "forumArticleCommentCell", for: indexPath) as! forumArticleCommentCell
            cell.commentAuthorName.text = forumArticleCommentData[indexPath.row-1]["commentAuthorName"]
            cell.commentContent.text = forumArticleCommentData[indexPath.row-1]["commentContent"]
            cell.commentAuthorImage.image = UIImage(named:forumArticleCommentData[indexPath.row-1]["commentAuthorImage"]!)
            cell.commentDate.text = forumArticleCommentData[indexPath.row-1]["commentDate"]
            return cell
        }
    }
}
