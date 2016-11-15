import UIKit
import SwiftyJSON
import PlaygroundSupport
import Alamofire
import Foundation
PlaygroundPage.current.needsIndefiniteExecution = true
//用URLSession實現R
var token:String = ""
let url = URL(string: "http://139.162.24.178/api/v1/login")
var request = URLRequest(url: url!)
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

request.httpMethod = "POST"
//設定body內容
let postString = "email=superuser@meatme.com&password=finalproject"
//let postString2 = "auth_token=fptsmFsJAYu_PB81sQ8Q&name=Justin&address=AlphaCamp&tel=1111111111"
//把body內容轉換成Data
let postStringData = postString.data(using: String.Encoding.utf8)
let postTask = URLSession.shared.uploadTask(with: request, from: postStringData, completionHandler:{ (data:Data?, response:URLResponse?, error:Error?) -> Void in
    if error != nil{
        print("post出錯")
        return
    }
    if let backData = data{
        print(backData)
        let jsonData = JSON(data:backData).dictionaryValue
        if let tokenString = jsonData["auth_token"]?.stringValue{
            print(tokenString)
            token = tokenString
        }
        
    }
})
//postTask.resume()

//var combineUrlString = "http://139.162.24.178/api/v1/sites?auth_token=Edd8SUTbCK1uw_docCdF"

var combineUrlString = "http://herogwp.xyz/videos"
let url2 = URL(string: combineUrlString)
var request2 = URLRequest(url: url2!)
request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
request2.httpMethod = "POST"
//設定body內容
let postString2 = ["video":["name":"Justin","description":"AlphaCamp","url_address":"https://www.youtube.com/watch?v=F8ujmPQBNbY"]]
//把body內容轉換成Data
let postStringData2 = try JSONSerialization.data(withJSONObject: postString2, options: [])
let postTask2 = URLSession.shared.uploadTask(with: request2, from: postStringData2, completionHandler:{ (data:Data?, response:URLResponse?, error:Error?) -> Void in
    if error != nil{
        print("post出錯")
        return
    }
    if let backData = data{
        print(backData)
        let jsonData = JSON(data:backData)//.dictionaryValue
        print(jsonData)
        //if let tokenString = jsonData["auth_token"]?.stringValue{
        //    print(tokenString)
        //}
        
    }
})
//postTask2.resume()

//

//let parameters = ["video[name]":"Justin","video[description]":"AlphaCamp","video[url_address]":"https://www.youtube.com/watch?v=F8ujmPQBNbY"] as [String : Any]
//Alamofire.request("http://herogwp.xyz/videos", method: HTTPMethod.post, parameters: parameters, encoding:JSONEncoding.default).response {
//    (response: DefaultDataResponse) in
//    print(response.request)
//    print(response.response)
//}



//用Alamofire的upload實現C
//網址
let url3 = URL(string: "http://139.162.24.178/api/v1/posts?auth_token=9rPU95G-jJRLHq_jA6hh")
//把Name字串轉換成Data型別
let postName = "alamoFire測試name"
let postNameData = postName.data(using: String.Encoding.utf8)
//把Content字串轉換成Data型別
let postContent = "alamoFire測試content"
let postContentData = postContent.data(using: String.Encoding.utf8)
//把照片轉成Data型別
let image = UIImage(named: "多肉植物01.jpg")
let imageData = UIImageJPEGRepresentation(image!, 1.0)
//用upload指令
//
//upload(multipartFormData: { (multipartFormData:MultipartFormData) in
//    multipartFormData.append(postNameData!, withName: "post[title]")
//    multipartFormData.append(postContentData!, withName: "post[content]")
//傳圖時記得要用帶fileName的方法
//    multipartFormData.append(imageData!, withName: "post[photo]", fileName: "image.jpg", mimeType: "image/jpeg")
//}, to: url3!
//    , encodingCompletion: {(multipartFormDataEncodingResult) in
//    switch multipartFormDataEncodingResult{
//    case .success:
//        print("Post成功")
//    case .failure(let encodingError):
//        print(encodingError)
//    }
//})

