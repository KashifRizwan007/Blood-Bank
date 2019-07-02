//
//  ViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/7/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var e_mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StaticLinker.sign_inViewController = self
        signInBtn.layer.cornerRadius = 10
        loader.isHidden = true
        loader.hidesWhenStopped = true
        self.e_mail.text = "g@gmail.com"
        self.password.text = "qwerty"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.loader.stopAnimating()
        self.signInBtn.isEnabled = true
    }
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    @IBAction func sign_inBtn(_ sender: Any) {
        signInBtn.isEnabled = false
        loader.isHidden = false
        loader.startAnimating()
        if(!((e_mail.text?.isEmpty)! || (password.text?.isEmpty)!)){
            _=sign_inDetails(e_mail: e_mail.text!, password: password.text!)
            Auth.auth().signIn(withEmail: e_mail.text!, password: password.text!, completion: { (user, error) in
                if user != nil{
                    StaticLinker.currentUserUid = user?.user.uid
                    StaticLinker.email = self.e_mail.text!
                    self.getData()
                    return
                }
                else{
                    let signInAlert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    signInAlert.addAction(action)
                    self.loader.stopAnimating()
                    self.signInBtn.isEnabled = true
                    self.present(signInAlert, animated: true, completion: nil)
                }
            })
        }
        else{
            let alertController = UIAlertController(title: "Alert", message: "No field should be left empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            loader.stopAnimating()
            self.signInBtn.isEnabled = true
        }
    }
    func getData(){
        let ref = Database.database().reference()
        ref.child("user").child("donor").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                let data = snapshot.value as! [String:Any]
                StaticLinker.bloodGrp = data["bloodGroup"] as! String
                StaticLinker.currentUserType = "donor"
                self.performSegue(withIdentifier: "sign_in", sender: self)
            }
        })
        ref.child("user").child("acceptor").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                let data = snapshot.value as! [String:Any]
                StaticLinker.bloodGrp = data["bloodGroup"] as! String
                StaticLinker.currentUserType = "acceptor"
                self.performSegue(withIdentifier: "sign_in", sender: self)
            }
        })
        
    }
}
