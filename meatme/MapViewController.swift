//
//  MapViewController.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/9.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import UIKit
import GoogleMaps

enum TravelMode: Int {
    case driving
    case walking
    case bicycling
}

class MapViewController: UIViewController {
    
    //MARK: - Variables
    var locationManager: CLLocationManager = CLLocationManager()
    var didFindMyLocation: Bool = false
    deinit {
        print("deinit: \(didFindMyLocation)")
    }
    var mapTask = MapTasks()
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!
    
    var markerArray: [GMSMarker] = []
    var waypointArray : [String] = []
    
    var travelMode = TravelMode.driving
    
    //紀錄按下路線規劃的查詢地址，reCreateRoute()用
    var origin = ""
    var destination = ""
    
    //MARK: - @IBOutlet
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var barButtonFindAddress: UIBarButtonItem!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var mytexfield: UITextField!
    //MARK: - Controller Property & Func
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 48.857165, longitude: 2.354613, zoom: 15)
        
        viewMap.camera = camera
        
        //CLLocationManagerDelegate protocol
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //GMSMapViewDelegate protocol
        viewMap.delegate = self
        
        //The current location of the user is described by a property of the map view object named "myLocation"
        //This property is that is a KVO-compliant (key-value observing compliant), meaning that we simply have to observe for changes on its value, and
        //that way we’ll be able to know when the user’s location gets updated.
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if !didFindMyLocation {
            //This "change" dictionary is passed as a parameter to the method by the system, and by using the NSKeyValueChangeNewKey key we can fetch the new value of the changed property we observe.
            let myLocation: CLLocation = change?[NSKeyValueChangeKey.newKey] as! CLLocation
            
            viewMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
            viewMap.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    //    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    //        <#code#>
    //    }
    
    //MARK: - @IBAction
    @IBAction func findAddress(_ sender: AnyObject) {
        let addressAlert = UIAlertController(title: "位置搜尋", message: "請輸入想查詢的地址", preferredStyle: .alert)
        
        addressAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "地址?"
        }
        
        let findAction = UIAlertAction(title: "開始", style: .default) { (action: UIAlertAction) in
            if let address = addressAlert.textFields?[0].text {
                self.mapTask.geocodeAddress(address, withCompletionHandler: { (status: String, success: Bool) in
                    if success == false {
                        
                        if status == "ZERO_RESULTS" {
                            self.showAlertWithMessage(alertMessage: "無法定位至該地址")
                        }
                        
                        //print("==========\(status)==========")
                    } else {
                        let coordinate = CLLocationCoordinate2D(latitude: self.mapTask.fatchedAddressLatitude!, longitude: self.mapTask.fatchedAddressLongitude!)
                        
                        self.viewMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
                        
                        self.setuplocationMarker(with: coordinate)
                    }
                })
            }
        }
        
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        
        self.present(addressAlert, animated: true, completion: nil)
    }
    
    @IBAction func createRoute(_ sender: AnyObject) {
        let directionAlert = UIAlertController(title: "規劃路線", message: "連結兩個地址:", preferredStyle: .alert)
        
        directionAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "出發地?"
        }
        
        directionAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "目的地?"
        }
        
        let createRouteAction = UIAlertAction(title: "開始", style: .default) { (action: UIAlertAction) in
            if self.routePolyline != nil {
                self.clearRoute()
                self.waypointArray.removeAll(keepingCapacity: false)
            }
            
            if let originAddress = directionAlert.textFields?[0].text, let destinationAddress = directionAlert.textFields?[1].text {
                
                self.mapTask.getDirections(origin: originAddress, destination: destinationAddress, waypoints: nil, travelMode: nil, completionHandler: { (status, success) in
                    if success == false {
                        //if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage(alertMessage: "無法規劃該路線")
                        //}
                    } else {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                        self.displayRouteInfo()
                        
                        self.origin = originAddress
                        self.destination = destinationAddress
                    }
                })
            }
        }
        
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        
        directionAlert.addAction(createRouteAction)
        directionAlert.addAction(closeAction)
        
        self.present(directionAlert, animated: true, completion: nil)
    }
    
    @IBAction func changeMapType(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "地圖類型", message: "請選擇", preferredStyle: .actionSheet)
        
        //一般道路地圖。 會顯示道路、一些人造特徵，以及重要的自然特徵 (例如河流)。 也可以看見道路與特徵標籤。
        let normalTypeAction = UIAlertAction(title: "一般", style: .default) { (action: UIAlertAction) in
            self.viewMap.mapType = kGMSTypeNormal
        }
        // 地形測量資料。 地圖包括色彩、等高線與標籤，以及透視陰影。 也可以看見一些道路與標籤。
        let terrianTypeAction = UIAlertAction(title: "地形", style: .default) { (action: UIAlertAction) in
            self.viewMap.mapType = kGMSTypeTerrain
        }
        //衛星圖資料加上道路地圖。 也可以看見道路與特徵標籤。
        let hybridTypeAction = UIAlertAction(title: "混合", style: .default) { (action: UIAlertAction) in
            self.viewMap.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "關閉", style: .cancel) { (action: UIAlertAction) in
            
        }
        
        actionSheet.addAction(normalTypeAction)
        actionSheet.addAction(terrianTypeAction)
        actionSheet.addAction(hybridTypeAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    //導航模式的選擇
    @IBAction func changeTravelMode(_ sender: AnyObject) {
        let modeAction = UIAlertController(title: "旅行模式", message: "請選擇:", preferredStyle: .actionSheet)
        
        let drivingAction = UIAlertAction(title: "開車", style: .default) { (action: UIAlertAction) in
            self.travelMode = .driving
            self.reCreateRoute()
        }
        
        let walkingAction = UIAlertAction(title: "步行", style: .default) { (action: UIAlertAction) in
            self.travelMode = .walking
            self.reCreateRoute()
        }
        
        let bicyclingAction = UIAlertAction(title: "腳踏車", style: .default) { (action: UIAlertAction) in
            self.travelMode = .bicycling
            
            self.showAlertWithMessage(alertMessage: "很抱歉，單車路線不在我們目前涵蓋的服務範圍內")
            //self.reCreateRoute()
        }
        
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        
        modeAction.addAction(drivingAction)
        modeAction.addAction(walkingAction)
        modeAction.addAction(bicyclingAction)
        modeAction.addAction(closeAction)
        
        present(modeAction, animated: true, completion: nil)
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            viewMap.isMyLocationEnabled = true
        }
    }
}

//MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if routePolyline != nil {
            
            // %f : 64-bit floating-point number (double).
            let positionString = String(coordinate.latitude) + "," + String(coordinate.longitude)
            
            mapTask.reverseGeoCode(positionString, withCompletionHandler: { (status, success) in
                if success == true {
                    //加上途經地點waypoints
                    self.waypointArray.append(self.mapTask.reverseGeoCodeAddress!)
                }
            })
            
            self.reCreateRoute()
        }
    }
}

//MARK: - User Defined Method
extension MapViewController {
    func showAlertWithMessage(alertMessage: String){
        let alert = UIAlertController(title: "SmallGmaps", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "關閉", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setuplocationMarker(with coordinate: CLLocationCoordinate2D) {
        //讓map上維持只有一個Marker
        if locationMarker != nil {
            //移除標記
            //透過將 GMSMarker 的 map 屬性設定為 nil，將標記從地圖上移除。也可以透過呼叫 GMSMapView clear 方法，以移除目前地圖上的所有疊加層 (包括標記)。
            locationMarker.map = nil
        }
        
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = viewMap
        locationMarker.title = mapTask.fatehedFormattedAddress
        locationMarker.snippet = "Wonderful place!"
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        //locationMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
        locationMarker.icon = UIImage(named: "多肉Marker")
        
        locationMarker.opacity = 0.8
        //扁平化標記
        //標記圖示通常是參考螢幕繪製在相對位置；旋轉、傾斜或縮放地圖時，都不會變更標記的方向。
        //可以將標記的方向設定成扁平並與地球表面貼合。這種標記方向會隨著地圖一起旋轉，並會在地圖傾斜時變更視角。扁平標記的大小會在地圖縮放時維持不變。
        locationMarker.isFlat = true
    }
    
    func configureMapAndMarkersForRoute() {
        if originMarker != nil {
            originMarker.map = nil
        }
        
        if destinationMarker != nil {
            destinationMarker.map = nil
        }
        
        originMarker = GMSMarker(position: mapTask.originCoordinate!)
        originMarker.map = viewMap
        originMarker.title = mapTask.originAddress!
        originMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        
        destinationMarker = GMSMarker(position: mapTask.destinateCoordinate!)
        destinationMarker.map = viewMap
        destinationMarker.title = mapTask.destinationAddress
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        
        //        if waypointArray.count > 0 {
        //            for waypoint in waypointArray {
        //
        //                let lat = Double(waypoint.components(separatedBy: ",")[0])
        //                let lng = Double(waypoint.components(separatedBy: ",")[1])
        //
        //                let waypointMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: lng!))
        //
        //                waypointMarker.map = viewMap
        //                waypointMarker.icon = GMSMarker.markerImage(with: UIColor.brown)
        //
        //                markerArray.append(waypointMarker)
        //            }
        //        }
    }
    
    func drawRoute() {
        let route = mapTask.overviewPolyine?["points"].stringValue
        
        let path: GMSPath = GMSPath(fromEncodedPath: route!)!
        
        //        let path2 = GMSMutablePath()
        //
        //        for index in 0...path.count()-1 {
        //            path2.add(path.coordinate(at: index))
        //        }
        
        //TODO : test steps points
        
        print("=====path:\(path)=====")
        //print("=====path2:\(path2)=====")
        
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = viewMap
        routePolyline.strokeColor = UIColor.magenta
        routePolyline.strokeWidth = 3.0
        
        let styles = [GMSStrokeStyle.solidColor(UIColor.black),GMSStrokeStyle.solidColor(UIColor.clear)]
        let lengths = [15,15]
        routePolyline.spans = GMSStyleSpans(path, styles, lengths as [NSNumber], kGMSLengthRhumb)
        
        //In order to make your map view fit the polyline of the route you are drawing
        var bounds = GMSCoordinateBounds()
        
        for index in 1...path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        
        viewMap.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    func displayRouteInfo() {
        labelInfo.text = mapTask.totalDistance + "\n" + mapTask.totalDuration
    }
    
    func reCreateRoute() {
        if routePolyline != nil {
            clearRoute()
            
            mapTask.getDirections(origin: origin, destination: destination, waypoints: waypointArray, travelMode: travelMode, completionHandler: { (status, success) in
                if success == false {
                    //if status == "ZERO_RESULTS" {
                    self.showAlertWithMessage(alertMessage: "無法規劃該路線")
                    //}
                } else {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
            })
        }
    }
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markerArray.count > 0 {
            for marker in markerArray {
                marker.map = nil
            }
            
            markerArray.removeAll(keepingCapacity: false)
        }
    }
}

