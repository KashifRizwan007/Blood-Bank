//
//  profileViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/8/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import UIKit

class profileViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bloodGrp: UILabel!
    @IBOutlet weak var gender: UILabel!
    var user:User!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.hidesWhenStopped = true
        loader.startAnimating()
        self.image.layer.borderWidth = 1
        self.image.layer.masksToBounds = false
        self.image.layer.borderColor = UIColor.black.cgColor
        self.image.layer.cornerRadius = image.frame.height/2
        self.image.clipsToBounds = true
        URLSession.shared.dataTask( with: NSURL(string:self.user.imageUrl)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.image.image = UIImage(data: data)
                    self.loader.stopAnimating()
                }
            }
        }).resume()
        name.text = user.name
        bloodGrp.text = user.bloodGroup
        gender.text = user.gender
    }
    @IBAction func call(_ sender: Any) {
        if UIApplication.shared.canOpenURL(URL(string:"tel://\(user.phone_no)")!) {
            UIApplication.shared.open(URL(string:"tel://\(user.phone_no)")!, options: [:], completionHandler: nil)
        }
    }
    @IBAction func message(_ sender: Any) {
        if UIApplication.shared.canOpenURL(URL(string: "sms:\(user.phone_no)")!) {
            UIApplication.shared.open(URL(string: "sms:\(user.phone_no)")!, options: [:], completionHandler: nil)
        }
    }
    @IBAction func email(_ sender: Any) {
        if UIApplication.shared.canOpenURL(URL(string: "mailto:\(user.e_mail)")!) {
            UIApplication.shared.open(URL(string: "mailto:\(user.e_mail)")!, options: [:], completionHandler: nil)
        }
    }
}
