//
//  DistanceTravelled.swift
//  UserLocation
//
//  Created by Himanshu H. Padia on 20/11/17.
//  Copyright © 2017 TechWorld. All rights reserved.
//

import UIKit
import MapKit

class DistanceTravelled: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDistance:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        self.lblDistance.text = "Traveled Distance: 0.0\nTotal Traveled Distance: 0.0"
    }
    
    fileprivate func performOperation(_ totalTravelledDistance: Double?, _ travelledDistance: Double?) {
        // display local notification
        self.appDelegate.displayNotification()
        // core data operation
        let context = self.appDelegate.persistentContainer.viewContext
        let task = History (context: context)
        
        task.historydate = String(describing: Date().string(with: "E, d MMM yyyy HH:mm:ss"))
        task.totaldistance = String(totalTravelledDistance!.rounded(toPlaces: 4))
        task.travaldistance = String(travelledDistance!.rounded(toPlaces: 4))
        // Save the data to coredata
        self.appDelegate.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        
        LocationService.sharedLocationServices.requestTravelledDistance { (travelledDistance, totalTravelledDistance, error) in
            if error != nil {
                self.lblDistance.text = "Unable to get Location, Please allow location access from setting. (\(String(describing: error)))"
                return
            }
            self.lblDistance.text = "Traveled Distance: \(travelledDistance!)\nTotal Traveled Distance: \(totalTravelledDistance!)"
            if travelledDistance! >= LocationService.sharedLocationServices.userTravelledDistance {
                self.performOperation(totalTravelledDistance, travelledDistance)
            }
        }
    }
}
