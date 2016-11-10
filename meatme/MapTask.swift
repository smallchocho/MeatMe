//
//  MapTask.swift
//  meatme
//
//  Created by Justin Huang on 2016/11/9.
//  Copyright © 2016年 Justin Huang. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON
import Alamofire

class MapTasks {
    
    //MARK: - Geocode properties
    let baseURLGeoCode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: [String: Any]?
    
    var fatehedFormattedAddress: String?
    
    var fatchedAddressLongitude: Double?
    
    var fatchedAddressLatitude: Double?
    
    var reverseGeoCodeAddress: String?
    
    //MARK: - Directions properties
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var originAddress: String?
    
    var destinationAddress: String?
    
    var originCoordinate: CLLocationCoordinate2D?
    
    var destinateCoordinate: CLLocationCoordinate2D?
    
    var selectedRoute: JSON?
    
    var overviewPolyine: JSON?
    
    //MARK: - Duartion & Distance properties
    var totalDistanceInMeter: Int = 0
    
    var totalDistance: String = ""
    
    var totalDurationInSeconds: Int = 0
    
    var totalDuration: String = ""
    
    
    //MARK: - Func
    func reverseGeoCode(_ latlng: String?, withCompletionHandler completionHandler:@escaping ( _ status: String, _ success: Bool) -> Void) {
        if let findLatLng = latlng {
            var reverseGeoCodeURLString = baseURLGeoCode + "latlng=" + findLatLng
            reverseGeoCodeURLString = reverseGeoCodeURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            request(reverseGeoCodeURLString).responseJSON(completionHandler: { (response: DataResponse<Any>) in
                switch response.result {
                case .success(let value):
                    let dictionary = JSON(value)
                    
                    if let status = dictionary["status"].string {
                        if status == "OK" {
                            let results = dictionary["results"].arrayValue
                            
                            let reverseAddress = results[0]["formatted_address"].stringValue
                            
                            self.reverseGeoCodeAddress = reverseAddress
                            
                            print("=====\(reverseAddress)=====")
                            
                            completionHandler(status, true)
                        }else {
                            completionHandler(status, false)
                        }
                    }
                case .failure(let error):
                    print("\n==========\(error.localizedDescription)==========\n")
                    completionHandler("", false)
                }
            })
            
        }
    }
    
    func geocodeAddress(_ address: String?, withCompletionHandler completionHandler: @escaping (_ status: String, _ success: Bool) -> Void ) {
        
        if let lookupAddress = address {
            
            var geocodeURLString = baseURLGeoCode + "address=" + lookupAddress
            
            //print("\n==========\(geocodeURLString)==========\n")
            
            geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            //print("\n==========\(geocodeURLString)==========\n")
            
            /* ========== Alamofire ========== */
            request(geocodeURLString).responseJSON(completionHandler: { (response: DataResponse<Any>) in
                switch response.result {
                case .success(let value):
                    let dictionary = JSON(value)
                    
                    if let status = dictionary["status"].string {
                        if status == "OK" {
                            let results = dictionary["results"].arrayValue
                            
                            self.lookupAddressResults    = results[0].dictionary
                            self.fatehedFormattedAddress = results[0]["formatted_address"].string
                            self.fatchedAddressLatitude  = results[0]["geometry"]["location"]["lat"].double
                            self.fatchedAddressLongitude = results[0]["geometry"]["location"]["lng"].double
                            
                            completionHandler(status, true)
                        } else {
                            completionHandler(status, false)
                        }
                    }
                case .failure(let error):
                    print("\n==========\(error.localizedDescription)==========\n")
                    completionHandler("", false)
                }
            })
            
            /* ========== Origin ========== */
            
            guard let geocodeURL = URL(string: geocodeURLString) else {
                print("\n==========load JSON files failed===========\n")
                completionHandler("load JSON files failed", false)
                return
            }
            
            DispatchQueue.main.async {
                do{
                    let geocodeData = try Data(contentsOf: geocodeURL)
                    
                    //print("\n==========\(geocodeData)==========\n")
                    
                    var error: NSError?
                    
                    let dictionary = JSON(data: geocodeData, options: JSONSerialization.ReadingOptions.mutableContainers, error: &error)
                    
                    if error != nil {
                        print("\n==========\(error?.localizedDescription)==========\n")
                        completionHandler("", false)
                    }
                    
                    if let status = dictionary["status"].string {
                        if status == "OK" {
                            let results = dictionary["results"].arrayValue
                            
                            self.lookupAddressResults    = results[0].dictionary
                            self.fatehedFormattedAddress = results[0]["formatted_address"].string
                            self.fatchedAddressLatitude  = results[0]["geometry"]["location"]["lat"].double
                            self.fatchedAddressLongitude = results[0]["geometry"]["location"]["lng"].double
                            
                            completionHandler(status, true)
                        } else {
                            completionHandler(status, false)
                        }
                    }
                } catch let e as NSError {
                    print("\n==========\(e.localizedDescription)==========\n")
                }
            }
            
        } else {
            completionHandler("No valid address", false)
        }
    }
    
    func getDirections(origin: String?, destination: String?, waypoints: [String]!, travelMode: Any?, completionHandler: @escaping (_ status: String, _ success: Bool)->Void) {
        
        if let originAddress = origin {
            if let destiionAddress = destination {
                var queryURLString = baseURLDirections + "origin=" + originAddress + "&destination= " + destiionAddress
                queryURLString = queryURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                //if there are waypoints to use
                //                if let routewaypoints = waypoints {
                //                    queryURLString += "&waypoints=optimize:true"
                //
                //                    for each in routewaypoints {
                //                        queryURLString += "|" + each.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                //                    }
                //                }
                
                if let travel = travelMode{
                    var travelModeString = ""
                    
                    switch travel {
                    case TravelMode.driving:
                        travelModeString = "driving"
                    case TravelMode.walking:
                        travelModeString = "walking"
                    case TravelMode.bicycling:
                        travelModeString = "bicycling"
                    default:
                        travelModeString = "driving"
                    }
                    
                    queryURLString += "&mode=" + travelModeString
                }
                
                print("=====origin:\(origin)=====")
                print("=====destination:\(destination)=====")
                
                /* ========== Alamofire ========== */
                request(queryURLString).responseJSON(completionHandler: { (response: DataResponse<Any>) in
                    switch response.result {
                    case .success(let value):
                        let dictionary = JSON(value)
                        
                        if let status = dictionary["status"].string {
                            if status == "OK" {
                                self.selectedRoute   = dictionary["routes"][0] // is a dictionary
                                self.overviewPolyine = dictionary["routes"][0]["overview_polyline"]
                                
                                //print("\n==========\(dictionary["routes"][0]["overview_polyline"].dictionaryValue)===========\n")
                                
                                let legs = dictionary["routes"][0]["legs"]
                                
                                self.originAddress = legs[0]["start_address"].string
                                self.destinationAddress = legs[legs.count-1]["end_address"].string
                                
                                self.originCoordinate = CLLocationCoordinate2D(latitude: legs[0]["start_location"]["lat"].doubleValue, longitude: legs[0]["start_location"]["lng"].doubleValue)
                                
                                self.destinateCoordinate = CLLocationCoordinate2D(latitude: legs[legs.count-1]["end_location"]["lat"].doubleValue, longitude: legs[legs.count-1]["end_location"]["lng"].doubleValue)
                                
                                self.calculateTotalDistanceAndDuration()
                                
                                completionHandler(status, true)
                            } else {
                                print("=====status:\(status)=====")
                                completionHandler(status, false)
                            }
                        }
                    case .failure(let error):
                        print("\n==========\(error.localizedDescription)==========\n")
                        completionHandler("", false)
                    }
                })
                
                
                /* ========== Origin ========== */
                /*
                 guard let directionURL = URL(string: queryURLString) else {
                 print("\n==========load JSON files failed===========\n")
                 completionHandler("load JSON files failed", false)
                 return
                 }
                 
                 DispatchQueue.main.async {
                 do {
                 let directionData = try Data(contentsOf: directionURL)
                 
                 var error: NSError?
                 
                 let dictionary = JSON(data: directionData, options: [], error: &error)
                 
                 if error != nil {
                 print("\n==========\(error?.localizedDescription)==========\n")
                 completionHandler("", false)
                 }
                 
                 if let status = dictionary["status"].string {
                 if status == "OK" {
                 self.selectedRoute   = dictionary["routes"][0] // is a dictionary
                 self.overviewPolyine = dictionary["routes"][0]["overview_polyline"]
                 
                 print("\n==========\(dictionary["routes"][0]["overview_polyline"].dictionaryValue)===========\n")
                 
                 let legs = dictionary["routes"][0]["legs"]
                 
                 self.originAddress = legs[0]["start_address"].string
                 self.destinationAddress = legs[legs.count-1]["end_address"].string
                 
                 self.originCoordinate = CLLocationCoordinate2D(latitude: legs[0]["start_location"]["lat"].doubleValue, longitude: legs[0]["start_location"]["lng"].doubleValue)
                 
                 self.destinateCoordinate = CLLocationCoordinate2D(latitude: legs[legs.count-1]["end_location"]["lat"].doubleValue, longitude: legs[legs.count-1]["end_location"]["lng"].doubleValue)
                 
                 self.calculateTotalDistanceAndDuration()
                 
                 completionHandler(status, true)
                 } else {
                 completionHandler(status, false)
                 }
                 }
                 } catch let e as NSError {
                 print("\n==========\(e.localizedDescription)==========\n")
                 }
                 }
                 */
            } else {
                completionHandler("destiionAddress is nil", false)
            }
        } else {
            completionHandler("originAddress is nil", false)
        }
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = selectedRoute?["legs"].arrayValue
        
        for each in legs! {
            totalDistanceInMeter += each["distance"]["value"].intValue
            totalDurationInSeconds += each["duration"]["value"].intValue
        }
        
        if totalDistanceInMeter < 1000 {
            totalDistance = "Total Distance: \(totalDistanceInMeter) 公尺"
        } else {
            let distanceInKm = Double(totalDistanceInMeter) / 1000
            totalDistance = "Total Distance: \(distanceInKm) 公里"
        }
        
        let mins  = totalDurationInSeconds / 60
        let hours = mins / 60
        let days  = hours / 24
        
        let remainingHours = hours % 24
        let remainingMins  = mins % 60
        let remainingSecs  = totalDurationInSeconds % 60
        
        if days == 0 {
            totalDuration = "Duration: \(remainingHours) 小時, \(remainingMins) 分, \(remainingSecs) 秒"
        } else {
            totalDuration = "Duration: \(days) 天, \(remainingHours) 小時, \(remainingMins) 分, \(remainingSecs) 秒"
        }
    }
    
    //A single response from the Directions API can give us more than one possible routes for going from point A to point B.
    //Each route is composed by legs, where a leg is just a part of the journey described in the Directions API response.
    //A simple route without any waypoints (locations between origin and destination) has only one leg, but as new waypoints are added to the route, the legs are increased accordingly.
    //Each leg is composed by steps, where a step is a direction unit, meaning an instruction regarding the direction the route should follow.
}
