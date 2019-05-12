//
//  user.swift
//  BloodBankFinal
//
//  Created by Kashif Rizwan on 3/8/19.
//  Copyright © 2019 Kashif Rizwan. All rights reserved.
//

import Foundation

class User{
    var name:String
    var e_mail:String
    var phone_no:Int
    var userType:Bool
    var bloodGroup:String
    var password:String
    var gender:String
    var imageUrl:String
    
    init(name:String,e_mail:String,phone_no:Int,userType:Bool,bloodGroup:String,password:String,gender:String,imageUrl:String) {
        self.name=name
        self.e_mail=e_mail
        self.phone_no=phone_no
        self.userType=userType
        self.bloodGroup=bloodGroup
        self.password=password
        self.gender=gender
        self.imageUrl=imageUrl
    }
}
