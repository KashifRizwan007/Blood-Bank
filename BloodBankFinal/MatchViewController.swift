//
//  MatchViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 5/17/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//
import UIKit
import FirebaseDatabase

class MatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var data = [String:User]()
    var ref: DatabaseReference!
    var profile:User!
    var filterArr = Array<User>()
    var userType:String = ""
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var donorFilter = ["O+":["O+", "O-"],
                          "O-":["O-"],
                          "A+":["A+", "A-", "O+", "O-"],
                          "A-":["A-", "O-"],
                          "B+":["B+", "B-", "O+", "O-"],
                          "B-":["B-", "O-"],
                          "AB+":["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
                          "AB-":["AB-", "A-", "B-", "O-"]]
    var acceptorFilter = ["O+":["O+", "A+", "B+", "AB+"],
                       "O-":["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
                       "A+":["A+", "AB+"],
                       "A-":["A-", "A+", "AB-", "AB+"],
                       "B+":["B+", "AB+"],
                       "B-":["B-", "B+", "AB-", "AB+"],
                       "AB+":["AB+"],
                       "AB-":["AB-", "AB+"]]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell") as! MatchTableViewCell
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
        self.profile = filterArr[indexPath.row]
        self.performSegue(withIdentifier: "match", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "match"{
            let profileViewControllerVariable=segue.destination as? profileViewController
            profileViewControllerVariable?.hidesBottomBarWhenPushed = true
            profileViewControllerVariable!.user = self.profile
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
        var filter = self.acceptorFilter
        if StaticLinker.currentUserType == "acceptor"{
            filter = self.donorFilter
        }
        while(i != arr.count){
            if (filter[StaticLinker.bloodGrp]?.contains(arr[i].bloodGroup))! && StaticLinker.email != arr[i].e_mail{
                filterArr.append(arr[i])
            }
            i += 1
        }
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
        
        if StaticLinker.currentUserType == "acceptor"{
            self.userType = "donor"
        }else{
            self.userType = "acceptor"
        }
        self.getData()
    }
    func getData() -> Void{
        ref = Database.database().reference()
        
        ref.child("user").child(self.userType).observe(.childAdded) {(snapshot) in
            let autoID = snapshot.key
            let obj = snapshot.value as! [String:Any]
            let name = obj["name"] as! String
            let email = obj["email"] as! String
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
        ref.child("user").child(self.userType).observe(.childRemoved) {(snapshot) in
            let autoID = snapshot.key
            self.data[autoID] = nil
            self.filter()
            self.tableView.reloadData()
        }
        ref.child("user").child(self.userType).observe(.childChanged) {(snapshot) in
            let autoID = snapshot.key
            let obj = snapshot.value as! [String:Any]
            let name = obj["name"] as! String
            let email = obj["email"] as! String
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
        performSegue(withIdentifier: "set", sender: self)
    }
}
