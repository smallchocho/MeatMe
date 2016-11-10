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
request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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

var combineUrlString = "http://139.162.24.178/api/v1/sites?auth_token=Vm4MEBYZzk9WXyuq4-Wh"

let url2 = URL(string: combineUrlString)


var request2 = URLRequest(url: url2!)
//request2.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
request2.httpMethod = "POST"
//設定body內容

let postString2 = "site[name]=Justin&site[address]=AlphaCamp&site[tel]=1111111111"
//把body內容轉換成Data
let postStringData2 = postString.data(using: String.Encoding.utf8)
let postTask2 = URLSession.shared.uploadTask(with: request2, from: postStringData2, completionHandler:{ (data:Data?, response:URLResponse?, error:Error?) -> Void in
    if error != nil{
        print("post出錯")
        return
    }
    if let backData = data{
        print(backData)
        let jsonData = JSON(data:backData).dictionaryValue
        if let tokenString = jsonData["auth_token"]?.stringValue{
            print(tokenString)
        }
        
    }
})
//postTask2.resume()

//
//
//let parameters = ["site[name]":"Justin","site[address]":"AlphaCamp","site[tel]":"1111111","auth_token":"Vm4MEBYZzk9WXyuq4-Wh"] as [String : Any]
//Alamofire.request("http://139.162.24.178/api/v1/sites", method: HTTPMethod.post, parameters: parameters, encoding: URLEncoding.default).response {
//    (response: DefaultDataResponse) in
//    print(response.request)
//    print(response.response)
//}
