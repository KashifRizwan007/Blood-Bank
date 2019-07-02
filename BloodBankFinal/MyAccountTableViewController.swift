//
//  MyAccountTableViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/15/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MyAccountTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    var profileImg:UIImage!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone_no: UILabel!
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    @IBOutlet weak var imgLoader: UIActivityIndicatorView!
    var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityView.center = self.view.center
        self.activityView.color = .black
        let barButton = UIBarButtonItem(customView: activityView)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        self.activityView.hidesWhenStopped = true
        
        self.activityView.startAnimating()
        self.imgLoader.hidesWhenStopped = true
        self.imgLoader.startAnimating()
        self.getData()
        
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.borderColor = UIColor.black.cgColor
        self.profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
    }
    func getData(){
        let ref = Database.database().reference()
        ref.child("user").child(StaticLinker.currentUserType).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                let data = snapshot.value as! [String:Any]
                let e_mail = data["email"] as! String
                let name = data["name"] as! String
                let phone_no = data["phone_no"] as! Int
                let userType = data["userType"] as! Bool
                let password = data["password"] as! String
                let bloodGroup = data["bloodGroup"] as! String
                let gender = data["gender"] as! String
                let url = data["imageURL"] as! String
                StaticLinker.user = User(name: name, e_mail: e_mail, phone_no: phone_no, userType: userType, bloodGroup: bloodGroup, password: password, gender: gender, imageUrl: url)
                self.loadData()
            }
        })
        
    }
    func loadData(){
        self.activityView.stopAnimating()
        URLSession.shared.dataTask( with: NSURL(string:StaticLinker.user.imageUrl)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.profileImage.image = UIImage(data: data)
                    self.imgLoader.stopAnimating()
                }
            }
        }).resume()
        self.name.text = StaticLinker.user.name
        self.email.text = StaticLinker.user.e_mail
        self.phone_no.text = String(StaticLinker.user.phone_no)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1,0]{//change profile photo
            self.changeprofilePhoto()
        }else if indexPath == [1,1]{//change phone no.
            self.changePhoneNo()
        }else if indexPath == [1,2]{//change password
            
        }else if indexPath == [2,0]{//signOut
            self.signOut()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func signOut(){
        let signOutAlert = UIAlertController(title: "Sign-Out", message: "Are you sure you want to Sign-Out?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Ok", style: .default, handler: {action in
            try! Auth.auth().signOut()
            self.performSegue(withIdentifier: "log_Out", sender: self)
        })
        signOutAlert.addAction(action)
        let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        signOutAlert.addAction(action1)
        self.present(signOutAlert, animated: true, completion: nil)
    }
    func changeprofilePhoto(){
        self.selectImage()
    }
    func changePhoneNo(){
        let alert = UIAlertController(title: "Change Phone no.", message: "Please enter new phone number.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction) in
            let ref:DatabaseReference = Database.database().reference()
            if let ph_no = self.textField.text{
                let data = Int(ph_no)
            ref.child("user").child(StaticLinker.currentUserType).child((Auth.auth().currentUser?.uid)!).child("phone_no").setValue(data)
                self.phone_no.text = ph_no
            }
        }))
            self.present(alert, animated: true, completion: nil)
    }
    func changePassword(){
        
    }
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!
            self.textField?.placeholder = String(StaticLinker.user.phone_no)
            self.textField.keyboardType = .phonePad
        }
    }
    func uploadImage() {
        self.imgLoader.startAnimating()
        let data = UIImageJPEGRepresentation(self.profileImg, 0.4)
        if let imageData = data{
            
            let imageUpload = Storage.storage().reference().child("Images").child((Auth.auth().currentUser?.uid)!).child("profilePic.jpg")
                _ = imageUpload.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    let errorAlert = UIAlertController(title: "Alert", message: error as? String, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    errorAlert.addAction(action)
                    self.loadData()
                    self.present(errorAlert, animated: true, completion: nil)
                    return
                }else{
                    imageUpload.downloadURL(completion: { (url, error) in
                        if let error = error {
                            let errorAlert = UIAlertController(title: "Alert", message: error as? String, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            errorAlert.addAction(action)
                            self.present(errorAlert, animated: true, completion: nil)
                            return
                        }else{
                            let ref:DatabaseReference = Database.database().reference()
                        ref.child("user").child(StaticLinker.currentUserType).child((Auth.auth().currentUser?.uid)!).child("imageURL").setValue(url?.absoluteString)
                            StaticLinker.user.imageUrl = (url?.absoluteString)!
                            self.loadData()
                        }
                    })
                }
            }
        }
    }
    func selectImage() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Photo", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: {action in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        })
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {action in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        })
        let removeAction = UIAlertAction(title: "Remove Photo", style: .default, handler: {action in
            self.profileImg = #imageLiteral(resourceName: "profile")
            self.uploadImage()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
        })
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(removeAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImg = image
            self.profileImage.image = nil
            self.uploadImage()
            dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
