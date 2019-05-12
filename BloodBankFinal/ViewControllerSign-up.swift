//
//  ViewControllerSign-up.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/8/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewControllerSign_up: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var userType:Bool = true
    var bloodGroup:String = ""
    var _gender:String = ""
    var ref:DatabaseReference!
    let pickerViewBloodGroups=["A+","A-","B+","B-","AB+","AB-","O+","O-"]
    @IBOutlet weak var edit: UILabel!
    
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
        bloodGroup = pickerViewBloodGroups[row]
        return
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        
        submit.layer.cornerRadius = 10
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        loader.isHidden = true
        
        let bounds: CGRect = edit.bounds
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: ([.bottomLeft, .bottomRight]), cornerRadii: CGSize(width: 1000.0, height: 500.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        edit.layer.mask = maskLayer
    }
    @objc func tapDetected() {
        self.selectImage()
    }
    @IBOutlet weak var donorRecipient: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gender: UISwitch!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var submit: UIButton!
    
    @IBAction func submit(_ sender: Any) {
        loader.isHidden = false
        submit.isEnabled = false
        loader.hidesWhenStopped = true
        loader.startAnimating()
        if(donorRecipient.isOn){
            userType = true
        }else{
            userType = false
        }
        if gender.isOn == false{
            _gender = "male"
        }else{
            _gender = "female"
        }
        if(name.text != nil || email.text != nil || password.text != nil || phoneNumber.text != nil){
            Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: {(user,error) in
                if let err = error?.localizedDescription{
                    let signInAlert = UIAlertController(title: "Alert", message: err, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    signInAlert.addAction(action)
                    self.present(signInAlert, animated: true, completion: nil)
                    self.loader.stopAnimating()
                    self.submit.isEnabled = true
                }else{
                    self.ref = Database.database().reference()
                    let user = Auth.auth().currentUser
                    //upload image
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.6)
                    let userId:String = (user?.uid)!
                    let imageUpload = Storage.storage().reference().child("Images/\(userId)/profilePic.jpg")
                    _ = imageUpload.putData(data!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            let errorAlert = UIAlertController(title: "Alert", message: error as? String, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            errorAlert.addAction(action)
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
                                }
                                else{
                                    let details:[String:Any] = ["name":self.name.text!,"email":self.email.text!,"phone_no":Int(self.phoneNumber.text!) ?? "","userType":self.userType,"bloodGroup":self.bloodGroup,"password":self.password.text ?? "" ,"gender":self._gender,"imageURL":url!.absoluteString]
                                    if self.userType==false{
                                        self.ref.child("user").child("donor").child((user?.uid)!).updateChildValues(details)
                                    }else if self.userType==true {
                                        self.ref.child("user").child("acceptor").child((user?.uid)!).updateChildValues(details)
                                    }
                                    let _ = ViewController()
                                    StaticLinker.sign_inViewController.e_mail.text = self.email.text
                                    self.navigationController?.popViewController(animated: true)
                                    self.loader.stopAnimating()
                                    self.submit.isEnabled = true
                                }
                            })
                        }
                    }
                }
            })
        }else{
            let signInAlert = UIAlertController(title: "Alert", message: "No field should be left empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            signInAlert.addAction(action)
            self.present(signInAlert, animated: true, completion: nil)
            self.loader.stopAnimating()
            self.submit.isEnabled = true
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
            self.imageView.image = #imageLiteral(resourceName: "profile")
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
            imageView.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
