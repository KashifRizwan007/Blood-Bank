//
//  DonorViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/8/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class donorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var data = [String:User]()
    var profile:User!
    var filterArr = Array<User>()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var filterValue = "Any"
    let pickerViewBloodGroups=["Any","A+","A-","B+","B-","AB+","AB-","O+","O-"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "donorCell") as! donorTableViewCell
        cell.name.text = filterArr[indexPath.row].name
        cell.bloodGrp.text = "Blood Group: " + filterArr[indexPath.row].bloodGroup
        URLSession.shared.dataTask( with: NSURL(string:self.filterArr[indexPath.row].imageUrl)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    cell.profilePicture.image = UIImage(data: data)
                }
            }
        }).resume()
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profile = filterArr[indexPath.row]
        self.performSegue(withIdentifier: "donor", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "donor"{
            let profileViewController=segue.destination as? profileViewController
            profileViewController?.hidesBottomBarWhenPushed = true
            profileViewController!.user = profile
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                activityView.stopAnimating()
            }
        }
    }
    func filter() -> Void{
        var arr:Array<User> = Array(self.data.values)
        filterArr.removeAll()
        var i = 0
        if filterValue == "Any"{
            while(i != arr.count){
                if StaticLinker.email != arr[i].e_mail{
                    filterArr.append(arr[i])
                }
                i += 1
            }
        }else{
            while(i != arr.count){
                if arr[i].bloodGroup == filterValue && StaticLinker.email != arr[i].e_mail{
                    filterArr.append(arr[i])
                }
                i += 1
            }
        }
        if StaticLinker.currentUserType == nil{
            StaticLinker.currentUserType = "acceptor"
        }
    }
    @IBAction func filter(_ sender: Any) {
        self.filterValue = "Any"
        let alertView = UIAlertController(
            title: "Select Blood Group",
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert)
        
        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        alertView.view.addSubview(pickerView)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.filter()
            self.tableView.reloadData()
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(alertView, animated: true, completion: {
            pickerView.frame.size.width = alertView.view.frame.size.width
        })
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewBloodGroups[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewBloodGroups.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.filterValue = pickerViewBloodGroups[row]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        activityView.center = self.view.center
        activityView.color = .black
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        
        self.view.addSubview(activityView)
        ref = Database.database().reference()
        ref.child("user").child("donor").observe(.childAdded) {(snapshot) in
            let autoID = snapshot.key
            let obj = snapshot.value as! [String:Any]
            let name = obj["name"] as! String
            let email = obj["email"] as! String
            let phone_no:Int = obj["phone_no"] as! Int
            let userType = obj["userType"] as! Bool
            let password = obj["password"] as! String
            let bloodGroup = obj["bloodGroup"] as! String
            let gender = obj["gender"] as! String
            let url = obj["imageURL"] as! String
            self.data[autoID] = User(name: name, e_mail: email, phone_no: phone_no, userType: userType, bloodGroup: bloodGroup, password: password, gender: gender, imageUrl: url)
            self.filter()
            self.tableView.reloadData()
        }
        ref.child("user").child("donor").observe(.childRemoved) {(snapshot) in
            let autoID = snapshot.key
            self.data[autoID] = nil
            self.filter()
            self.tableView.reloadData()
        }
        ref.child("user").child("donor").observe(.childChanged) {(snapshot) in
            let autoID = snapshot.key
            let obj = snapshot.value as! [String:Any]
            let email = obj["email"] as! String
            let name = obj["name"] as! String
            let phone_no = obj["phone_no"] as! Int
            let userType = obj["userType"] as! Bool
            let password = obj["password"] as! String
            let bloodGroup = obj["bloodGroup"] as! String
            let gender = obj["gender"] as! String
            let url = obj["imageURL"] as! String
            
            self.data[autoID] = User(name: name, e_mail: email, phone_no: phone_no, userType: userType, bloodGroup: bloodGroup, password: password, gender: gender, imageUrl: url)
            self.filter()
            self.tableView.reloadData()
        }
        
    }
    @IBAction func settings(_ sender: Any) {
        performSegue(withIdentifier: "settings", sender: self)
    }
}
