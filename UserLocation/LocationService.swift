//
//  LocationService.swift
//  UserLocation
//
//  Created by Himanshu H. Padia on 21/11/17.
//  Copyright © 2017 TechWorld. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationService : NSObject {
    
    private let locationManager = CLLocationManager()
    
    static let sharedLocationServices = LocationService()
    
    private var reverseGeoLocation: ((CLLocation?,String?,Error?)->Void)?
    private var travelledDistance: ((Double?,Double?,Error?)->Void)?
    
    private var isTravelledDistace: Bool = false
    var userTravelledDistance: Double = 50.0
    
    var currentLocation : CLLocation?
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
    var totalTraveledDistance: Double = 0
    
    private override init() {
        super.init()
        self.setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 50        
    }
    
    private func proccssGeoCode(location:CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: processResponse(withPlacemarks:error:))
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            self.reverseGeoLocation?(nil,nil,error)
        } else {
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let pm = placemarks[0]
                    var addressString = ""
                    if pm.name != nil {
                        addressString = addressString + pm.name! + ", "
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    print(addressString)
                    self.reverseGeoLocation?(pm.location,addressString,nil)
                    print("==================")
                } else {
                    self.reverseGeoLocation?(nil,nil,error)
                }
            }
        }
        self.clearReverseGeoLocation()
    }
    
    private func clearReverseGeoLocation() {
        self.reverseGeoLocation = nil
    }
    
    public func requestReverseGeocodeLocation(reverseGeoLocation: ((CLLocation?,String?,Error?)->Void)?) {
        self.reverseGeoLocation = reverseGeoLocation
        if currentLocation == nil {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            return
        }
        self.proccssGeoCode(location: self.currentLocation!)
    }
    
    public func requestTravelledDistance(travelledDistance: ((Double?,Double?,Error?)->Void)?) {
        self.travelledDistance = travelledDistance
        self.isTravelledDistace = true
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
    }
    
    private func processTravelDistance(_ locations: [CLLocation]) {
        if startDate == nil {
            startDate = Date()
        } else {
            print("elapsedTime:", String(format: "%.0fs", Date().timeIntervalSince(startDate)))
        }
        
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            totalTraveledDistance += lastLocation.distance(from: location)
            traveledDistance += lastLocation.distance(from: location)
            print("Traveled Distance:\(traveledDistance.rounded(toPlaces: 4)),Total Traveled Distance:\(totalTraveledDistance.rounded(toPlaces: 4))")
            self.travelledDistance?(traveledDistance.rounded(toPlaces: 4),totalTraveledDistance.rounded(toPlaces: 4),nil)
            // IF TRAVELED DISTANCE IS >= 50 RESET TRAVEL DISTANCE
            if traveledDistance >= self.userTravelledDistance {
                // Reset to default value
                traveledDistance = 0.0
                self.travelledDistance?(traveledDistance.rounded(toPlaces: 4),totalTraveledDistance.rounded(toPlaces: 4),nil)
                startDate = Date()
            }
        }
        lastLocation = locations.last
    }
}

extension LocationService : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil{
            currentLocation = locations.last
        }
        
        if isTravelledDistace {
            self.processTravelDistance(locations)
        }
        // if any geo location request call for it.
        if self.reverseGeoLocation != nil {
            self.proccssGeoCode(location: currentLocation!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        if self.reverseGeoLocation != nil {
            self.reverseGeoLocation?(nil,nil,error)
            self.clearReverseGeoLocation()
        }
    }
}

