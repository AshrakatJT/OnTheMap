//
//  LocationMapViewController.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 21/03/2022.
//

import UIKit
import MapKit

class LocationMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapPins()
        tabBarController?.tabBar.isHidden = false
    }
    
    
    func userAlert() {
        let alert = UIAlertController(title: "Warning", message: "you already posted your location. Would you like to overwrite it?", preferredStyle: .alert)
        let action = UIAlertAction(title:"Overwrite", style: .default)
        { action in
            if let vc = self.storyboard?.instantiateViewController(identifier: "AddPinViewController") as? AddPinViewController
            {
                vc.loadView()
                vc.viewDidLoad()
                vc.linkTextField.text = UdacityClient.User.link
                vc.locationTextField.text = UdacityClient.User.location
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                fatalError("alert error")
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addPin(_ sender: Any){
        if UdacityClient.User.createdAt == "" {
            performSegue(withIdentifier: "AddStudentFromMapView", sender: nil)
        } else {
        userAlert()
        }
    }
    
    @IBAction func refresh(_ sender:Any){
        mapPins()
    }
    
    @IBAction func logout(_ sender: Any){
        UdacityClient.logout {
            success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("logged out")
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Failed", message: "Logout Failed. Please try again", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mapPins() {
        
        UdacityClient.getStudentLocations {
            studentlocationresults, error in
            if error == nil{
                Student.locations = studentlocationresults
                
                var annotations = [MKPointAnnotation]()
                for student in Student.locations {
                let lat = CLLocationDegrees(student.latitude)
                let long = CLLocationDegrees(student.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    annotation.title = "\(student.firstName)" + " " + "\(student.lastName)"
                annotation.subtitle = student.mediaURL
                    annotations.append(annotation)
                self.mapView.addAnnotation(annotation)
                    }
        } else {
            let alert = UIAlertController(title: "Error", message: "Failed loading data", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reusedId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
       
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let  toOpen = view.annotation?.subtitle! {
                app.canOpenURL(URL(string: toOpen)!)
                app.open(URL(string: toOpen)!)
            }
        }
    }


}
