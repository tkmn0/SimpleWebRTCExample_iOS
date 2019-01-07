//
//  ViewController.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/01/05.
//  Copyright © 2019年 tkmngch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var webRTCClient: WebRTCClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRTCClient = WebRTCClient()
        webRTCClient.setup()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        let localVideoView = webRTCClient.localVideoView()
        localVideoView.center.y = self.view.center.y
        self.view.addSubview(localVideoView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

