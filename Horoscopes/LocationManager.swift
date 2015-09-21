//
//  LocationManager.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/24/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var currentLocation : CLLocation!
    
    override init(){
        
    }
    
    // MARK: actions
    
    /*
    http://stackoverflow.com/questions/7888896/current-location-permission-dialog-disappears-too-quickly
    
    While difficult to track down, the solution for this is quite simple.
    
    Through much trial and error I found out that while the location access dialog pops up when you try to access any location services in the app for the first time, the dialog disappears on its own (without any user interaction) if the CLLocationManager object is released before the user responds to the dialog.
    
    I was creating a CLLocationManager instance in my viewDidLoad method. Since this was a local instance to the method, the instance was released by ARC after the method completed executing. As soon as the instance was released, the dialog disappeared. The solution was rather simple. Change the CLLocationManager instance from being a method-level variable to be a class-level instance variable. Now the CLLocationManager instance is only released once the class is unloaded.
    */
    func setupLocationService() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.NotDetermined {
            // TODO: handle if location service disable or denied
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        } else {
            // for iOS 8
            if #available(iOS 8.0, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.NotDetermined {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        XAppDelegate.finishedGettingLocation(manager.location!)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
        // get this error in simulator, on device what should we do?
//        self.dismissViews()
        
        
    }
}
