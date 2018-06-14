//
//  ViewController.swift
//  demo
//
//  Created by jiajun zheng on 2018/6/13.
//  Copyright © 2018年 nebulasio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var sn = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pay(_ sender: Any) {
        sn = NASSmartContracts.randomCodeWithLength(length: 32)
        let error = NASSmartContracts.payNasWith(nas: 0.000001,
                                                 address: "n1a4MqSPPND7d1UoYk32jXqKb5m5s3AN6wB",
                                                 sn: sn,
                                                 name: "test1",
                                                 desc: "desc")
        if error != nil {
            print("\(String(describing: error?.userInfo["msg"]))")
            NASSmartContracts.goToNasNanoAppStore()
        }
    }
    
    @IBAction func Call(_ sender: Any) {
        sn = NASSmartContracts.randomCodeWithLength(length: 32)
        let error = NASSmartContracts.callWith(nas: 0,
                                               method: "save",
                                               args: ["key111","value111"],
                                               address: "n1zVUmH3BBebksT4LD5gMiWgNU9q3AMj3se",
                                               sn: sn,
                                               name: "test2",
                                               desc: "desc2")
        if error != nil {
            print("\(String(describing: error?.userInfo["msg"]))")
            NASSmartContracts.goToNasNanoAppStore()
        }
    }
    @IBAction func CheckStatus(_ sender: Any) {
        
        NASSmartContracts.checkStatusWith(sn: sn, headler: { (dic) in
            print(dic)
        }) { (code, msg) in
            print("code:\(code),msg:\(msg)")
        }
    }
    @IBAction func goToAppStore(_ sender: Any) {
        
        NASSmartContracts.goToNasNanoAppStore()
    }
    
}

