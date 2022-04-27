//
//  LocationConfirmationViewController.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 21/03/2022.
//

import UIKit
import MapKit

class LocationConfirmationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var  postActivityIndicator: UIActivityIndicatorView!
    
    var link: String = ""
    var location: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPin()
        tabBarController?.tabBar.isHidden = true
        postActivityIndicator.isHidden = true
    }
    
   
    func activityIndicator(_ running : Bool) {
        if running {
            DispatchQueue.main.async {
                self.postActivityIndicator.startAnimating()
            }
            
        } else {
            DispatchQueue.main.async {
                self.postActivityIndicator.stopAnimating()
            }
        }
        finishButton.isEnabled = !running
        postActivityIndicator.isHidden = !running
        
    }

    func createPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = self.latitude
        annotation.coordinate.longitude = self.longitude
        annotation.title = location
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(annotation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func handleGetUserData(firstName: String?, lastName: String?, error: Error?){
        if error == nil {
            UdacityClient.postLocation(firstName: firstName ?? "", lastName: lastName ?? "", mapString: location, mediaURL: link, latitude: latitude, longitude: longitude, completion: handlePostLocation(success:error:))
        } else {
            print("user data cannot be handled")
        }
    }
    
    func handlePostLocation(success:Bool, error: Error?){
        activityIndicator(false)
        if success {
            UdacityClient.User.location = location
            print(UdacityClient.User.location)
            UdacityClient.User.link = link
            print("location added")
            navigationController?.popToRootViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Location couldn't be added. Try again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            print("location couldn't be added")
        }
    }
    
    func handleUpdateLocation(success: Bool, error: Error?){
        if success {
            UdacityClient.User.location = location
            UdacityClient.User.link = link
            print("location updates")
            navigationController?.popToRootViewController(animated: true)
        } else {
            print("location cannot be updated")
        }
    }
    
    
    @IBAction func finishTapped(_ sender: Any) {
        activityIndicator(true)
        if UdacityClient.User.createdAt == "" {
            UdacityClient.getUserData(completion: handleGetUserData(firstName:lastName:error:))
        } else {
            UdacityClient.updateLocation(firstName: UdacityClient.User.firstName, lastName: UdacityClient.User.lastName, mapString: location, mediaURL: link, latitude: latitude, longitude: longitude, completion: handleUpdateLocation(success:error:))
        }
    }
    

        
    func mapView(_ mapView:MKMapView, viewFor annotation:MKAnnotation) -> MKAnnotationView? {
        let reusedId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
       
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView?.canShowCallout = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }


}
