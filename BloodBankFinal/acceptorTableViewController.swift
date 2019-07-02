//
//  acceptorTableViewController.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/8/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import UIKit

class acceptorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bloodGrp: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        self.profilePicture.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
