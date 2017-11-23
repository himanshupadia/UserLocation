//
//  FirstViewController.swift
//  UserLocation
//
//  Created by Himanshu H. Padia on 20/11/17.
//  Copyright © 2017 TechWorld. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class UserLocation: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView! = nil
    @IBOutlet weak var lblLocationAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LocationService.sharedLocationServices.requestReverseGeocodeLocation { (userLocation,addressString, error) in
            if error != nil {
                self.handleError(error: error)
                return
            }
            self.lblLocationAddress.text = addressString
            let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map.setRegion(region, animated: true)
        }
    }
    
    func handleError(error:Error?) {
        self.lblLocationAddress.text = "Unable to get Reverse Geocode Location (\(String(describing: error!)))"
        let alert = UIAlertController(title: "Unable to get Location", message: "Please allow location access from setting.", preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { action in
            switch action.style{
            case .default: UIApplication.shared.open((NSURL(string: UIApplicationOpenSettingsURLString)! as URL), options: [:], completionHandler: nil)
            case .cancel: print("cancel")
            case .destructive: print("destructive")
            }
        }))
    }
}
