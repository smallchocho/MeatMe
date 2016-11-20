//
//  FindMeatCameraController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/12.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class FindMeatCameraController: UIViewController{
    //GoogleVision變數
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    //從google拿到的data
    var resultOfPicData:Data?
    var meatMeSeverToken = "zCuw_Kf_yKpDZNArfM3f"
    var meatMeSeverUrl = "http://139.162.24.178/api/v1/plants/recognize?auth_token="
    var googleAPIKey = "AIzaSyA--Sr2_nkJIPnDWQDz-2-YSebGLJC4S1Q"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    //判斷工程模式有沒有被開啟
    var engineerModeIsLunch = false
    //從meatme Server拿到的Data
    var selectedDataAndArticleData:JSON?
    var backMessageFromServer = "有什麼事情出錯了喔"
    //是否第一次啟動相機的布林
    var isFirstLunchCamera = true
    //GoogleVision解析後顯示在畫面上的結果
    //    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nowLoading: UILabel!
    @IBOutlet weak var labelResults: UITextView!
    @IBOutlet weak var faceResults: UITextView!
    //讀取手機照片的按鈕
    @IBOutlet weak var loadImageButtonTapped: UIButton!
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func engineerModeButton(_ sender: UIButton) {
        if engineerModeIsLunch == false{
            self.labelResults.isHidden = false
            self.faceResults.isHidden = false
            self.engineerModeIsLunch = true
        }else{
            self.labelResults.isHidden = true
            self.faceResults.isHidden = true
            self.engineerModeIsLunch = false
        }
    }
    //傳送JSON資料給Sever的按鈕：
    @IBOutlet weak var postJSON: UIButton!
    @IBAction func postJSON(_ sender: UIButton) {
        //        getTokenFromServer(loginUrlString: "http://139.162.24.178/api/v1/login")
        toServerRequest(urlString: meatMeSeverUrl, httpMethod: "POST", contentType: "application/json",token: meatMeSeverToken)
    }
//轉換頁面
    @IBAction func goToSelectImagePage(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToSelectImagePage", sender: nil)
    }
    //拍照相關
    //拍照按鈕
    @IBAction func takePhotoButton(_ sender: UIButton) {
        takePhoto()
    }
    @IBOutlet weak var takePhotoButton: UIButton!
    //拍完照或從相簿挑選照片後要顯示在這
    @IBOutlet weak var meatImageView: UIImageView!

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GoogleVision相關
        imagePicker.delegate = self
//        spinner.hidesWhenStopped = true
    }
    override func viewDidAppear(_ animated: Bool) {
//        let storyboard = UIStoryboard(name: "Lunch", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "LunchScreen") as! LunchScreenController
//        present(viewController, animated: false, completion: nil)
//        塞一個背景圖
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "背景")!)
        //第一次啟動相機完畢後isFirstLunchCamera改成false
        if isFirstLunchCamera == true{
            takePhoto()
            isFirstLunchCamera = false
        }
        
    }
    override func viewDidLayoutSubviews() {
           }
    override func viewWillDisappear(_ animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToSelectImagePage"{
            let destination = segue.destination as! SecectImageController
            destination.getDataFromServer = selectedDataAndArticleData
            destination.chooseImage = meatImageView.image
        }
        if segue.identifier == "GoNoMeatPage"{
            let destination = segue.destination as! NoMeatPageController
            destination.chooseImage = meatImageView.image
            if backMessageFromServer == "notPlant"{
                destination.errorMessage = "您拍的不是植物喔，請再拍一次"
            }
            else if backMessageFromServer == "isPerson"{
                destination.errorMessage = "請問您是在自拍嗎？"
            }
            else{
                destination.errorMessage = "跟伺服器連線出現錯誤，請重試"
            }
        }
    }
}


//拍照功能相關方法
extension  FindMeatCameraController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func takePhoto(){
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        imagePicker.delegate = self
    }
    //啟動imagePickerController後按下使用後的行為
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if imagePicker.sourceType == .camera{
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            meatImageView.image = image
            //把照下來照片轉成base64
            let binaryImageData = base64EncodeImage(image)
            //傳送給Google解析
            createRequest(with: binaryImageData)
            //Loading按鈕顯示，拍照跟讀相簿按鈕消失
            loadingStatus()
            //3秒後傳送request給後台
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer:Timer) in
                self.toServerRequest(urlString: self.meatMeSeverUrl, httpMethod: "POST", contentType: "application/json",token: self.meatMeSeverToken)
                timer.invalidate()
            })
            self.dismiss(animated: true, completion: nil)
        }
        //啟動相簿
        if imagePicker.sourceType == .photoLibrary{
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                meatImageView.image = pickedImage
                //轉成Base64格式後傳給Google後得到Request
                let binaryImageData = base64EncodeImage(pickedImage)
                createRequest(with: binaryImageData)
                //Loading按鈕和圖片顯示，拍照跟讀相簿按鈕消失
                loadingStatus()
                //3秒後傳送request給後台
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer:Timer) in
                    self.toServerRequest(urlString: self.meatMeSeverUrl, httpMethod: "POST", contentType: "application/json",token: self.meatMeSeverToken)
                    timer.invalidate()
                })
            dismiss(animated: true, completion: nil)
        }
    }
    //imagePickerController按下取消執行的動作
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Loading按鈕消失，拍照跟讀相簿按鈕顯示
        normalStatus()
        dismiss(animated: true, completion: nil)
    }
    //產生一個照片儲存到Document的儲存路徑
    func setSavePhotoUrl()-> URL?{
        let fileManager = FileManager.default
        let docUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docUrl = docUrls.first
        let interval = Date.timeIntervalSinceReferenceDate
        let name = "\(interval).jpg"
        let url = try! docUrl?.appendingPathComponent(name)
        return url
    }
}


/// Image processing

extension FindMeatCameraController {
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let outprint = json.dictionaryObject!
            
            print("=================\n\(outprint)\n===================")
            let errorObj: JSON = json["error"]
            
//            self.spinner.stopAnimating()
           
//            self.labelResults.isHidden = false
//            self.faceResults.isHidden = false
            self.faceResults.text = ""
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get face annotations
                let faceAnnotations: JSON = responses["faceAnnotations"]
                if faceAnnotations != nil {
                    let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]
                    
                    let numPeopleDetected:Int = faceAnnotations.count
                    
                    self.faceResults.text = "People detected: \(numPeopleDetected)\n\nEmotions detected:\n"
                    
                    var emotionTotals: [String: Double] = ["sorrow": 0, "joy": 0, "surprise": 0, "anger": 0]
                    var emotionLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY":0.25, "VERY_UNLIKELY": 0.0]
                    
                    for index in 0..<numPeopleDetected {
                        let personData:JSON = faceAnnotations[index]
                        
                        // Sum all the detected emotions
                        for emotion in emotions {
                            let lookup = emotion + "Likelihood"
                            let result:String = personData[lookup].stringValue
                            emotionTotals[emotion]! += emotionLikelihoods[result]!
                        }
                    }
                    // Get emotion likelihood as a % and display in UI
                    for (emotion, total) in emotionTotals {
                        let likelihood:Double = total / Double(numPeopleDetected)
                        let percent: Int = Int(round(likelihood * 100))
                        self.faceResults.text! += "\(emotion): \(percent)%\n"
                    }
                } else {
                    self.faceResults.text = "No faces found"
                }
                
                // Get label annotations
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = "Labels found: "
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
                    self.labelResults.text = labelResultsText
                } else {
                    self.labelResults.text = "No labels found"
                }
            }
        })
    }
    

    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}


/// Networking

extension FindMeatCameraController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 9
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 9
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            self.resultOfPicData = data
            self.analyzeResults(data)
        }
        task.resume()
    }
    
    
}
//連接MeatME用
extension FindMeatCameraController{
    //傳送request給MeatMeServer:
    func toServerRequest(urlString:String,httpMethod:String,contentType:String,token:String){
        let combineUrlString = urlString + token
        let serverUrl = URL(string: combineUrlString)
        var postRequest = URLRequest(url: serverUrl!)
        //指定postRequest.httpMethod為”POST”
        postRequest.httpMethod = httpMethod
        //在POST的情況底下，如果沒特別注名的話預設是application/x-www-form-urlencoded的Content-Type
        postRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        //把從Google拿到的data包給server
        let postTask = URLSession.shared.uploadTask(with: postRequest, from: resultOfPicData, completionHandler:{ (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if error != nil{
                print("post出錯 \(error?.localizedDescription)")
                //這邊得要用主佇列的非同步進行畫面切換
                
                DispatchQueue.main.async {
                    self.normalStatus()
                    self.performSegue(withIdentifier: "GoNoMeatPage", sender: nil)
                }
                return
            }
            if response != nil{
                print("****\(response!)*****")
            }
            
            if let backData = data{
                //把結果轉成JSON存入selectedDataAndArticleData
                self.selectedDataAndArticleData = JSON(data: backData)
                let jsonBackData =  JSON(data: backData).dictionaryObject
                print("\n==========\(jsonBackData)==========\n")
                //Loading按鈕消失，拍照跟讀相簿按鈕顯示(要用主佇列的非同步進行)
                DispatchQueue.main.async {
                    self.normalStatus()
                    self.backMessageFromServer = JSON(data: backData)["message"].stringValue
                    print(self.backMessageFromServer)
                    if self.backMessageFromServer == "notPlant"||self.backMessageFromServer == "isPerson"{
                        self.performSegue(withIdentifier: "GoNoMeatPage", sender: nil)
                    }
                    else if self.backMessageFromServer == "isPlant"||self.backMessageFromServer == "isMeat"{
                        self.performSegue(withIdentifier: "GoToSelectImagePage", sender: nil)
                    }
                }
            }
        })
        postTask.resume()
    }
     //從MeatME得到token代入meatMeSeverToken
//    func getTokenFromServer(loginUrlString:String){
//        let url = URL(string: loginUrlString)
//        var request = URLRequest(url: url!)
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        //設定body內容
//        let postString = "email=superuser@meatme.com&password=finalproject"
//        //把body內容轉換成Data
//        let postStringData = postString.data(using: String.Encoding.utf8)
//        let postTask = URLSession.shared.uploadTask(with: request, from: postStringData, completionHandler:{ (data:Data?, response:URLResponse?, error:Error?) -> Void in
//            if error != nil{
//                print("post出錯 \(error?.localizedDescription)")
//                return
//            }
//            if let backData = data{
//                print(backData)
//                let jsonData = JSON(data:backData).dictionaryValue
//                if let tokenString = jsonData["auth_token"]?.stringValue{
//                    print(tokenString)
//                    self.meatMeSeverToken = tokenString
//                }
//            }
//        })
//        postTask.resume()
//    }
}

//
extension FindMeatCameraController{
    func loadingStatus(){
        //Loading按鈕和圖片顯示，拍照跟讀相簿按鈕消失
        self.nowLoading.isHidden = false
        self.meatImageView.isHidden = false
        self.loadImageButtonTapped.isHidden = true
        self.takePhotoButton.isHidden = true
    }
    func normalStatus(){
        //Loading按鈕和圖片消失，拍照跟讀相簿按鈕顯示
        self.nowLoading.isHidden = true
        self.meatImageView.isHidden = false
        self.loadImageButtonTapped.isHidden = false
        self.takePhotoButton.isHidden = false
    }
}




// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}




