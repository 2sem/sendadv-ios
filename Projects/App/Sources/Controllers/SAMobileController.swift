//
//  SAMobileController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 3. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import Contacts

class SAMobileController{
    //["ko-Kore" : "Korean", "en" : "English", "ja" : "Japanese", "zh-Hans" : "Chinese", "zh-Hant" : "Taiwanese"]
    static let mobilePrefixesForKor = ["+8210", "+8211", "+8216", "+8217", "+8218", "+8219", "8210", "8211", "8216", "8217", "8218", "8219", "010", "011", "016", "017", "018", "019"];
    //let mobilePrefixes : [String : [String]] = ["kor": mobilePrefixesForKor];
    static let Default = SAMobileController();
    
    func isMobile(phone : CNLabeledValue<CNPhoneNumber>) -> Bool{
        var value = false;
        let number = phone.value.stringValue;
        
        guard !number.isEmpty else{
            return value;
        }
        
        switch phone.label ?? ""{
            case CNLabelPhoneNumberMobile, CNLabelPhoneNumberiPhone:
                value = true
                break;
            default:
                value = self.isMobileNumber(number: number, prefixes: SAMobileController.mobilePrefixesForKor);
                break;
        }
        
        return value;
        
        //return !number.isEmpty && (phone.label == CNLabelPhoneNumberMobile || phone.label == CNLabelPhoneNumberiPhone);
        
//        for phone in contact.phoneNumbers{
//            var number = phone.value.stringValue;
//            guard self.isMobileNumber(number: number, prefixes: mobilePrefixesForKor) else{
//                continue;
//            }

    }
    
    func isMobileNumber(number: String, prefixes: [String]) -> Bool{
        var value = false;
        
        for prefix in prefixes{
            if number.hasPrefix(prefix){
                value = true;
                break;
            }
        }
        
        return value;
    }
}
