//
//  forumListController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/10.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
class forumListController: UIViewController{
    //sever相關變數
    var meatMeSeverToken = "?auth_token=zCuw_Kf_yKpDZNArfM3f"
    var meatMeSeverUrl = "http://139.162.24.178/api/v1/posts"
    var articleId:String?
    var getDataFromServer:JSON?
    var selectedIndexpathAtArticleList:IndexPath?
    @IBOutlet weak var loadingSpiner: UIActivityIndicatorView!
    @IBOutlet weak var forumListTableView: UITableView!
    var forumListData = [
        [
            "articleTitleId":"讀取中",
            "articleTitle":"讀取中",
            "articleCategory":"讀取中",
            "articleContent":"讀取中",
            "articleAuthorName":"讀取中",
            "articleAuthorImage":"讀取中",
            "articleImage":"讀取中",
            "articleDate":"讀取中",
            "articleLoveNumber":"0",
            "articleCommentNumber":"0"
        ]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        //把tableView的row高度設定為依照內容自動調整
        self.forumListTableView.rowHeight = UITableViewAutomaticDimension
        //這邊是給一個可能預測的高度
        self.forumListTableView.estimatedRowHeight = 120
        self.forumListTableView.delegate = self
        self.forumListTableView.dataSource = self
        if getDataFromServer == nil{
            self.loadingSpiner.startAnimating()
            self.getArticleListFromServer(UrlString: self.meatMeSeverUrl, token: self.meatMeSeverToken)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.forumListTableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoArticlePage"{
            guard let destination = segue.destination as? forumArticleController else{
                print("something is wrong")
                return
            }
            destination.getDataFromServer = self.getDataFromServer
            destination.articleId = self.articleId
            destination.selectedIndexpathAtArticleList = self.selectedIndexpathAtArticleList
        }
    }
}
extension forumListController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexpathAtArticleList = indexPath
        articleId = getDataFromServer?["plantArticles"][indexPath.row]["articleId"].stringValue
        performSegue(withIdentifier: "GoArticlePage", sender: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getDataFromServer != nil{
            return (getDataFromServer?["plantArticles"].arrayValue.count)!
        }else{
            return forumListData.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumListCell", for: indexPath) as! forumListCell
        if getDataFromServer != nil{
            cell.articleTitle.text = getDataFromServer?["plantArticles"][indexPath.row]["articleTitle"].stringValue
            print("@@@@/n\(getDataFromServer?["plantArticles"][indexPath.row]["articleTitle"].stringValue)/n@@@@@")
            cell.articleContent.text = getDataFromServer?["plantArticles"][indexPath.row]["articleContent"].stringValue
            cell.articleAuthorName.text = getDataFromServer?["plantArticles"][indexPath.row]["articleAuthorName"].stringValue
            let imageUrl = URL(string:(getDataFromServer?["plantArticles"][indexPath.row]["articleImage"].stringValue)!)
            cell.articleImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "讀取中"))
            cell.articleDate.text = getDataFromServer?["plantArticles"][indexPath.row]["articleDate"].stringValue
            cell.articleLoveNumber.text = getDataFromServer?["plantArticles"][indexPath.row]["articleLoveNumber"].stringValue
            cell.articleCommentNumber.text = getDataFromServer?["plantArticles"][indexPath.row]["articleCommentNumber"].stringValue
            return cell
        }else{
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
}


extension forumListController{
    //    向MeatME發request取得getDataFromServer的內容
    func getArticleListFromServer(UrlString:String,token:String){
        let UrlAndTokenString = UrlString + token
        let url = URL(string: UrlAndTokenString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        //設定body內容
        //把body內容轉換成Data
        let postTask = URLSession.shared.dataTask(with: request, completionHandler: {(data:Data?, response:URLResponse?, error:Error?) -> Void in
            guard error == nil else{
                print("something wrong")
                return
            }
            guard  let backData = data else{
                print("data is nil")
                return
            }
            
            self.getDataFromServer = JSON(data: backData)
            print(self.getDataFromServer)
            DispatchQueue.main.async {
                self.forumListTableView.reloadData()
                self.loadingSpiner.stopAnimating()
                
            }
        })
        postTask.resume()
    }
}
