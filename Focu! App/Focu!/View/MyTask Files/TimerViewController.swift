//
//  TimerViewController.swift
//  Focu!
//
//  Created by Philip Lagud on 20/7/20.
//  Copyright © 2020 Philip Lagud. All rights reserved.
//

import UIKit


class TimerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
           notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        

        // Do any additional setup after loading the view.
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    
    
    
    
}
