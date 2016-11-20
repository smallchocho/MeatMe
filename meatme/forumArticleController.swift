//
//  forumArticleController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/11.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit
import SwiftyJSON
class forumArticleController: UIViewController {
    var meatMeSeverToken = "?auth_token=zCuw_Kf_yKpDZNArfM3f"
    var meatMeSeverUrl = "http://139.162.24.178/api/v1/posts/"
    var articleId:String?
    var getDataFromServer:JSON?
    var getCommentFromServer:JSON?
    var selectedIndexpathAtArticleList:IndexPath!
    @IBOutlet weak var loadingSpiner: UIActivityIndicatorView!
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
            "commentContent":"讀取中",
            "commentAuthorName":"讀取中",
            "commentAuthorImage":"讀取中",
            "commentDate":"讀取中",
            ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //把tableView的row高度設定為依照內容自動調整
        self.forumArticleTableView.rowHeight = UITableViewAutomaticDimension
        //這邊是給一個可能預測的高度
        self.forumArticleTableView.estimatedRowHeight = 700
        self.forumArticleTableView.delegate = self
        self.forumArticleTableView.dataSource = self
        if getCommentFromServer == nil{
            self.loadingSpiner.startAnimating()
            let meatMeSeverUrlForComment = meatMeSeverUrl + articleId!
            self.getArticleCommentFromServer(UrlString: meatMeSeverUrlForComment, token: meatMeSeverToken)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension forumArticleController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getCommentFromServer != nil{
            return (getCommentFromServer?["palntArticleComments"].arrayValue.count)! + 1
        }else{
            return forumArticleCommentData.count + 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "forumArticleCell", for: indexPath) as! forumArticleCell
            if getDataFromServer != nil{
                cell.articleTitle.text = getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleTitle"].stringValue
                print("@@@@/n\(getDataFromServer?["plantArticles"][indexPath.row]["articleTitle"].stringValue)/n@@@@@")
                cell.articleContent.text = getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleContent"].stringValue
                cell.articleAuthorName.text = getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleAuthorName"].stringValue
                let imageUrl = URL(string:(getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleImage"].stringValue)!)
                cell.articleImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "讀取中"))
                
                let authorImageUrl = URL(string:(getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleAuthorImage"].stringValue)!)
                cell.articleAuthorImage.sd_setImage(with: authorImageUrl, placeholderImage: UIImage(named: "讀取中"))
                cell.articleAuthorImage.layer.cornerRadius = cell.articleAuthorImage.frame.height
                
//                cell.articleImage.translatesAutoresizingMaskIntoConstraints = true
//                cell.articleImage.frame = CGRect.init(x: cell.articleImage.frame.origin.x , y: cell.articleImage.frame.origin.y, width: 280, height: 160)
                cell.articleDate.text = getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleDate"].stringValue
                cell.articleLoveNumber.text = getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleLoveNumber"].stringValue
                cell.articleCommentNumber.text = getDataFromServer?["plantArticles"][selectedIndexpathAtArticleList.row]["articleCommentNumber"].stringValue
                return cell
            }
            else{
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
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "forumArticleCommentCell", for: indexPath) as! forumArticleCommentCell
            if getCommentFromServer != nil{
                cell.commentAuthorName.text = getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentAuthor"].stringValue
                print("^^^^^\(getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentAuthorName"].stringValue)^^^^^^")
                cell.commentContent.text = getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentContent"].stringValue
                print("^^^^^\(getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentContent"].stringValue)^^^^^^")
                let imageUrl = URL(string:(getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentAuthorImage"].stringValue)!)
                cell.commentAuthorImage.sd_setImage(with: imageUrl!, placeholderImage: UIImage(named: "讀取中"))
                cell.commentDate.text = getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentDate"].stringValue
                print("^^^^^\(getCommentFromServer?["palntArticleComments"][indexPath.row-1]["articleCommentDate"].stringValue)^^^^^^")
                return cell
            }else{
                cell.commentAuthorName.text = forumArticleCommentData[indexPath.row-1]["commentAuthorName"]
                cell.commentContent.text = forumArticleCommentData[indexPath.row-1]["commentContent"]
                cell.commentAuthorImage.image = UIImage(named:forumArticleCommentData[indexPath.row-1]["commentAuthorImage"]!)
                cell.commentDate.text = forumArticleCommentData[indexPath.row-1]["commentDate"]
                return cell
            }
        }
    }
}

    extension forumArticleController{
        //    向MeatME發request取得getDataFromServer的內容
        func getArticleCommentFromServer(UrlString:String,token:String){
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
                
                self.getCommentFromServer = JSON(data: backData)
                print(self.getCommentFromServer)
                DispatchQueue.main.async {
                    self.forumArticleTableView.reloadData()
                    self.loadingSpiner.stopAnimating()
                    
                }
            })
            postTask.resume()
        }
}
