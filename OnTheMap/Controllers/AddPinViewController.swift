//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 21/03/2022.
//
import UIKit
import MapKit

class AddPinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var linkTextField: UITextField!
    @IBOutlet var findLocation: UIButton!
    @IBOutlet var geocodeActivityIndicator: UIActivityIndicatorView!
    
    var latitude : Double = 0.0
    var longitude : Double = 0.0
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        geocodeActivityIndicator.isHidden = true
        locationTextField.delegate = self
        linkTextField.delegate = self
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Location", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        linkTextField.attributedPlaceholder = NSAttributedString(string: "Link", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        }
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag){
        nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
            return true
        }
    @IBAction func findLocation(_ sender: Any) {
        locationTextField.resignFirstResponder()
        linkTextField.resignFirstResponder()
        if locationTextField.text == "" || linkTextField.text == "" {
            userAlert()
        } else {
            guard let location = locationTextField.text
            else {
                return
            }
            findGeocode("\(location)")
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func userAlert() {
        let alert = UIAlertController(title:"Required Fields!" , message: "You must enter a location and URL", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        }
    
    func findGeocode(_ address: String) {
        activityIndicator(true)
        CLGeocoder().geocodeAddressString(address){
            (placemark, error) in
            if error == nil {
                if let placemark = placemark?.first,
                   let location = placemark.location {
                    self.latitude = location.coordinate.latitude
                    self.longitude = location.coordinate.longitude
                    
                    print("Latitude:\(self.latitude), Longitude:\(self.longitude)")
                    self.performSegue(withIdentifier: "FindLocationSegue", sender: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Geocode is not found. Please try again", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                print("geocode error")
            }
            self.activityIndicator(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FindLocationSegue" {
            if let mapVC = segue.destination as?
                LocationConfirmationViewController{
                mapVC.link = linkTextField.text ?? ""
                mapVC.location = locationTextField.text ?? ""
                mapVC.latitude = latitude
                mapVC.longitude = longitude
                
            }
        }
    }
    func activityIndicator(_ running: Bool){
        if running {
            DispatchQueue.main.async {
                self.geocodeActivityIndicator.startAnimating()
            }
            
        } else {
            DispatchQueue.main.async {
                self.geocodeActivityIndicator.stopAnimating()
            }
        }
        locationTextField.isEnabled = !running
        linkTextField.isEnabled = !running
        findLocation.isEnabled = !running
        geocodeActivityIndicator.isHidden = !running
    }

    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        func unsubscribeToKeyboardNotifications() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        @objc func keyboardWillShow(_ notification:Notification){
            if locationTextField.isEditing || linkTextField.isEditing  {
                view.frame.origin.y = -150
        }
    }
    
        @objc func keyboardWillHide(_ notification:Notification){
            view.frame.origin.y += 150
        }
        func getKeyboardHeight(_ notification:Notification) -> CGFloat {

            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.cgRectValue.height
        }
}

