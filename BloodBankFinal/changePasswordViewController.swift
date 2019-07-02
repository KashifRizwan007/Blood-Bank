//
//  changePasswordViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/20/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import UIKit
import Firebase

class changePasswordViewController: UIViewController {

    @IBOutlet weak var crntPass: UITextField!
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var confrmPass: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.hidesWhenStopped = true
    }
    @IBAction func save(_ sender: Any) {
        if newPass.text != confrmPass.text || crntPass.text == nil{
            if newPass.text != confrmPass.text{
                let alert = UIAlertController(title: "Alert", message: "New passwords donot match" , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            if crntPass.text == nil{
                let alert = UIAlertController(title: "Alert", message: "current password field cannot be empty" , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }else {
            loader.startAnimating()
            self.changePassword(email: StaticLinker.user.e_mail,currentPassword: self.crntPass.text!,newPassword: self.newPass.text!)
        }
    }
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func changePassword(email: String, currentPassword: String, newPassword: String) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (result,error) in
            if error == nil {
                Auth.auth().currentUser?.updatePassword(to: newPassword) { (errror) in
                    if error == nil{
                        self.navigationController?.popViewController(animated: true)
                        self.loader.stopAnimating()
                    }else{
                        let alert = UIAlertController(title: "Error updating Password", message: (errror as! String), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.loader.stopAnimating()
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.loader.stopAnimating()
            }
        })
    }
}
