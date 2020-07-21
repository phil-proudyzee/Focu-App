//
//  MyTasksViewController.swift
//  Focu!
//
//  Created by Philip Lagud on 14/7/20.
//  Copyright © 2020 Philip Lagud. All rights reserved.
//
/*

Tasks
1. Add a function that allows to add new cells inside the table.  Y
2. Add a function that deletes specific cells on a table. N
3. Create a pop up task edit menu using child view controllers. ?
4. Add a function that uses date picker view to set dates. Y
5. Add a function that allows to edit the name of the task. N
6. Add a function that sends user to the Timer storyboard once the cell is clicked. N


*/

import UIKit
import UserNotifications
import AVFoundation

class MyTasksViewController: UIViewController {
    
    var player: AVPlayer?
    
    @IBOutlet weak var timelabel: UILabel!
    
        // References an object named "Table", inheriting from the class UITableView.
        // ! Force unwrap
    
    @IBOutlet var table: UITableView!
        
        //declaring a "MyReminder" array
        var models = [MyReminder]()
    
        var timer = Timer()

    //---------// VIEW DID LOAD //---------//
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // specify what delegate and datasource for this tableview will be.
            table.delegate = self
            table.dataSource = self
            
            // remove top navbar line
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            
            //date at the top
            timelabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
            
            //background video
            playBackgroundVideo()
    
            
        }
    //---------// VIEW DID LOAD //---------//
    
    
    
    //date
    @objc func tick() {
        timelabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
    }
    
    //play background video
    
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
    }
    
    @objc func playerDidReachEnd() {
        player!.seek(to:CMTime.zero)
    }
    
        @IBAction func didTapAdd() {
            // show add view controller
            guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
                return
            }
            vc.title = "New Task"
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.completion = { title, body, date in
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    //calendar button
                    let new = MyReminder(title: title, date: date, identifer: "id_\(title)")
                    
                    self.models.append(new)
                    self.table.reloadData()
                    
                    //notification tempkate
                    let content =  UNMutableNotificationContent()
                    content.title = title
                    content.sound = .default
                    content.body = body
                    
                    let targetDate = date
                    
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                        if error != nil {
                            print("Error")
                        }
                        
                    })

                }
            }
            navigationController?.pushViewController(vc, animated: true)
    }
        
        @IBAction func didTapTest() {
            // show add view controller
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
                if success {
                    //schedule test
                    self.scheduleTest()
                    //label.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
                }
                else if error != nil {
                    print("Error occured.")
                }
            })
            
    }
    
    // notifications
            func scheduleTest() {
                let content =  UNMutableNotificationContent()
                content.title = "Error pid"
                content.sound = .default
                content.body = "Error subtitle"
                
                let targetDate = Date().addingTimeInterval(10)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("Error")
                    }
                    
                })
                
            }
    }



 // Delegates are used to handle interactions of cells.
    extension MyTasksViewController: UITableViewDelegate {
        // Capture everytime the user taps a cell
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }

    }

    extension MyTasksViewController: UITableViewDataSource {
        
        //number of rows shown in the table
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if models.count == 0 {
                    tableView.setEmptyView(title: "You have no tasks set.", message: "Tap the calendar button to add a new task.")
            }
                else {
                    tableView.restore()
            }
            return models.count
        }
        
        //
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            // Deque of cell: using the template cell over and over.
            // Dequeuing the cell is the proces of trying to see if there is a previous available cell and using it as a template for the new cell.
            // Index Path represents the position in the table. It is comprised of sections and rows, a table can have N number of sections and each section can have N number of rows. If we don't supply the sections then the default would be 1.
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = models[indexPath.row].title
            let date = models[indexPath.row].date
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM, dd, YYYY HH:mm:ss a"
            cell.detailTextLabel?.text = formatter.string(from: date)
            return cell
        }
    }

    // References // Constructor
    struct MyReminder {
        let title: String
        let date: Date
        let identifer: String
        
    }

//empty table

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        messageLabel.textColor = UIColor.lightGray
        
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        titleLabel.text = title
        
        messageLabel.text = message
        
        messageLabel.numberOfLines = 0
        
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        
        self.backgroundView = emptyView
        
        self.separatorStyle = .none
        }
    
        func restore() {
            self.backgroundView = nil
            self.separatorStyle = .singleLine
            }

    }
