//
//  forumListController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/10.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit

class forumListController: UIViewController{
    @IBOutlet weak var forumListTableView: UITableView!
    var forumListData = [
        ["articleTitle":"1111",
         "articleContent":"11111111",
         "articleAuthorName":"111111",
         "articleImage":"多肉植物01",
         "articleDate":"111111",
         "articleLoveNumber":"11",
         "articleCommentNumber":"11"
         ],
        ["articleTitle":"2222",
         "articleContent":"22222222",
         "articleAuthorName":"222222",
         "articleImage":"多肉植物02",
         "articleDate":"2222222",
         "articleLoveNumber":"22",
         "articleCommentNumber":"22"
        ],
        ["articleTitle":"3333",
         "articleContent":"33333333",
         "articleAuthorName":"3333333",
         "articleImage":"多肉植物03",
         "articleDate":"3333333",
         "articleLoveNumber":"33",
         "articleCommentNumber":"33"
        ],
        ["articleTitle":"4444",
         "articleContent":"44444444",
         "articleAuthorName":"444444",
         "articleImage":"多肉植物01",
         "articleDate":"4444444",
         "articleLoveNumber":"44",
         "articleCommentNumber":"44"
        ]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forumListTableView.delegate = self
        self.forumListTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension forumListController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forumListData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumListCell", for: indexPath) as! forumListCell
        cell.articleTitle.text = forumListData[indexPath.row]["articleTitle"]
        cell.articleContent.text = forumListData[indexPath.row]["articleContent"]
        cell.articleAuthorName.text = forumListData[indexPath.row]["articleAuthorName"]
        cell.articleImage.image = UIImage(named:forumListData[indexPath.row]["articleImage"]!)
        cell.articleDate.text = forumListData[indexPath.row]["articleDate"]
        cell.articleLoveNumber.text = forumListData[indexPath.row]["articleLoveNumber"]
        cell.articleCommentNumber.text = forumListData[indexPath.row]["articleCommentNumber"]
        return cell
    }
}
