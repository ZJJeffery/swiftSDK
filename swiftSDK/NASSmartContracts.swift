//
//  NASSmartContracts.swift
//  demo
//
//  Created by jiajun zheng on 2018/6/13.
//  Copyright © 2018年 nebulasio. All rights reserved.
//

import UIKit

let NAS_NANO_SCHEMA_URL = "openapp.nasnano://virtual?params="

let NAS_CALLBACK_DEBUG = "https://pay.nebulas.io/api/pay"
let NAS_CHECK_URL_DEBUG = "https://pay.nebulas.io/api/pay/query?payId="

let NAS_CALLBACK = "https://pay.nebulas.io/api/mainnet/pay"
let NAS_CHECK_URL = "https://pay.nebulas.io/api/mainnet/pay/query?payId="


class NASSmartContracts: NSObject {
    
    static var kNASCallback:String = NAS_CALLBACK
    static var kNASCheckUrl:String = NAS_CHECK_URL
    
    static var charSet:NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    /**
     * Go to debug mode. Default is product mode.
     **/
    class func debug(debug:Bool){
        if debug {
            kNASCallback = NAS_CALLBACK_DEBUG
            kNASCheckUrl = NAS_CHECK_URL_DEBUG
        }else {
            kNASCallback = NAS_CALLBACK
            kNASCheckUrl = NAS_CHECK_URL
        }
    }
    
    /**
     * Check if NasNano is installed.
     **/
    public class func nasNanoInstalled() -> Bool{
        let url = URL(string: NAS_NANO_SCHEMA_URL);
        return UIApplication.shared.canOpenURL(url!);
    }
    
    /**
     * Go to appstore for NasNano.
     **/
    public class func goToNasNanoAppStore() {
        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id1281191905?mt=8"]];
        let url = URL(string: "itms-apps://itunes.apple.com/cn/app/id1281191905?mt=8");
        let options = [UIApplicationOpenURLOptionUniversalLinksOnly : false]
        UIApplication.shared.open(url!, options: options, completionHandler: nil)
        
    }
    
    /**
     * Way to generate serialNumber.
     **/
    public class func randomCodeWithLength(length:NSInteger) -> String{
        let stringM = NSMutableString(string: "")
        for _ in 0...charSet.length {
            let index = Int(arc4random() % UInt32(charSet.length))
            let subString = charSet.substring(with: NSMakeRange(index, 1))
            stringM.append(subString)
        }
        return stringM.copy() as! String
    }
    
    /**
     * Pay for goods. Return nil if successful.
     **/
    public class func payNasWith(nas:Double, address:String, sn:String, name:String?, desc:String?) -> NSError? {
        let number = 1000000000000000000 * nas
        let wei = NSNumber(floatLiteral: number)
        let nameData = name != nil ? name! : ""
        let descData = desc != nil ? desc! : ""
        let info = [ "goods" : [ "name" : nameData, "desc" : descData],
                     "pay" : ["value" : wei, "to" : address,
                              "payload" : ["type" : "binary"], "currency" : "NAS"],
                     "callback" : kNASCallback] as [String : Any]
        let queryInfo = self.queryValueWith(sn: sn, info: info)
        let url = "\(NAS_NANO_SCHEMA_URL)\(queryInfo)"
        return self.openUrl(urlString: url);
    }
    
    /**
     * Call a smart contract function. Return nil if successful.
     **/
    public class func callWith(nas:Double, method:NSString?, args:NSArray, address:NSString, sn:String, name:NSString?, desc:NSString?) -> NSError? {
        let number = 1000000000000000000 * nas
        let wei = NSNumber(floatLiteral: number)
        let nameData = name != nil ? name! : ""
        let descData = desc != nil ? desc! : ""
        let methodData = method != nil ? method! : ""
        do {
            let argsArrayData = try JSONSerialization.data(withJSONObject: args, options: JSONSerialization.WritingOptions(rawValue: 0))
            let argsData = String(data: argsArrayData, encoding: String.Encoding.utf8)!
            let info = [ "goods" : [ "name" : nameData, "desc" : descData],
                         "pay" : ["value" : wei, "to" : address,
                                  "payload" : ["type" : "call", "function" : methodData, "args" : argsData], "currency" : "NAS"],
                         "callback" : kNASCallback] as [String : Any]
            let queryInfo = self.queryValueWith(sn: sn, info: info)
            let url = "\(NAS_NANO_SCHEMA_URL)\(queryInfo)"
            return self.openUrl(urlString: url);
        } catch _ {
            return nil;
        }
    }
    
    /**
     * Check status for an action.
     **/
    public class func checkStatusWith(sn:String, headler:((Dictionary<String, Any>) -> ())?, errorHandler:((Int, String) -> ())?) {
        let stringUrl = "\(kNASCheckUrl)\(sn)"
        let url = URL(string: stringUrl)!
        let request = URLRequest(url: url)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            if error != nil {
                
                if errorHandler != nil {
                    errorHandler!(-1, error!.localizedDescription)
                }
            }else {
                
                if let resDict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String : AnyObject] {
                    
                    if let code = resDict!["code"] as? Int {
                        
                        if code == 0 {
                            
                            if headler != nil {
                                
                                headler!(resDict!)
                            }
                            
                        }
                        
                        if errorHandler != nil {
                            let msg = resDict!["msg"]!
                            errorHandler!(code, msg as! String)
                        }
                    }
                }
            }
            
        } as URLSessionTask
        
        sessionDataTask.resume()
        
    }
    
    
    class func openUrl(urlString:String) -> NSError? {
        let url = URL(string: urlString)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { _ in
                
            }
            return nil;
        }
        let error = NSError(domain: "Need NasNano", code: -1, userInfo: ["mas" : "没安装Nebulas智能数字钱包，请下载安装"])
        return error;
    }
    
    class func queryValueWith(sn:String?, info:Dictionary<String, Any>?) -> String {
        
        let dict = NSMutableDictionary(dictionary: [:])
        dict.setObject("jump", forKey:"category" as NSString)
        dict.setObject("confirmTransfer", forKey: "des" as NSString)
        
        let pageParams = NSMutableDictionary(dictionary: [:])
        pageParams.setObject(sn != nil ? sn! : "", forKey: "serialNumber" as NSString)
        
        if info != nil {
            pageParams.addEntries(from: info!)
        }
        dict.setValue(pageParams, forKey: ("pageParams" as NSString) as String)
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let string = String(data: data!, encoding: String.Encoding.utf8)
        let result = string!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return result!;
    }
    
}
