//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by Ashrakat Sherif on 21/03/2022.
//

import Foundation
import UIKit

class LocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        UdacityClient.getStudentLocations { studentlocationresults, error in
            if error == nil {
                Student.locations = studentlocationresults
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Data couldn't load", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func logout(_ sender: Any){
        UdacityClient.logout {
            success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("logged out")
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Failed", message: "Logout failed. Please try again", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func addPin(_ sender:Any){
        if UdacityClient.User.createdAt == ""{
            performSegue(withIdentifier: "AddStudent", sender: nil)
        } else {
            userAlert()
        }
    }
    
    @IBAction func refresh(_ sender: Any){
        refreshButton.isEnabled = false
        UdacityClient.getStudentLocations {
            studentlocationresults, error in
            Student.locations = studentlocationresults
            self.tableView.reloadData()
        }
        refreshButton.isEnabled = true
    }
    
    
    
    func userAlert() {
        let alert = UIAlertController(title: "Warning", message: "you already posted your location. Would you like to overwrite it?", preferredStyle: .alert)
        let action = UIAlertAction(title:"Overwrite", style: .default)
        { action in
            if let vc = self.storyboard?.instantiateViewController(identifier: "AddPinViewController") as? AddPinViewController
            {
                vc.loadView()
                self.tabBarController?.tabBar.isHidden = true
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
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Student.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableCell", for: indexPath) as? LocationTableCell
        else {
            fatalError("error")
        }
        let student = Student.locations[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = Student.locations[indexPath.row]
        guard let url = URL(string: student.mediaURL)
        else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

