//
//  AddViewController.swift
//  Focu!
//
//  Created by Philip Lagud on 14/7/20.
//  Copyright © 2020 Philip Lagud. All rights reserved.
//

import UIKit
import AVFoundation
// import RealmSwift

class AddViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var player: AVPlayer?
    
    // Function that gets assigned from the controller that presents this controller, mechanism to hand back the information that the user has added. (Title, body, date). The other controller is responsible for scheduling this notification.
    
    // ? is optional. 
    
    public var completion: ((String, String, Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loading title and bodyfield delegates
        
        titleField.delegate = self
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        
        //background video
        playBackgroundVideo()
        
    }
    
    //background video function
    func playBackgroundVideo() {
        let path = Bundle.main.path(forResource: "rating5", ofType: ".mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player!.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        player!.seek(to: CMTime.zero)
        player!.play()
        self.player?.isMuted = true
        
    //background video function
    }

    @objc func playerDidReachEnd() {
        player!.seek(to:CMTime.zero)
    }
    
    // Validate if there is indeed in fact text in both of these fields and the user has a date picked.
    // ! Force Unwrap
    
    @objc dynamic func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
            let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            
            completion?(titleText, bodyText, targetDate)
            
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
            
        }
        
        
    }



}
