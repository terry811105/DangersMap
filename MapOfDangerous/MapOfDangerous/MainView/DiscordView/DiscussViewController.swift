//
//  InfoDiscordViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/15.
//

import UIKit
import SwiftKeychainWrapper
import WebKit
import SafariServices

class DiscussViewController: UIViewController, TitleTableViewCellDelegate {
    func needToLogIn(_ sender: TitleTableViewCell) {
        
        self.present(AlertManager.alertView(alertMessage: "需要登入或尚未驗證"), animated: true) {
            guard let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let model = self.model, let data = self.data else { return }
            model.fetchRangeDangerData(accountId: accountId, latitude: data.latitude, longitude: data.longitude)
        }
        
        
    }
    
    func didNothing(_ sender: TitleTableViewCell) {
        print("什麼都沒做")
        guard let token = KeychainWrapper.standard.string(forKey: "token"), let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let eventId = self.eventID, let model = self.model, let data = self.data else { return }
        APIManager.postWitness(eventId: eventId, accountId: accountId, token: token, isWitness: 0) { bool in
            if bool{
                print("上傳目擊事件成功")
                model.fetchRangeDangerData(accountId: accountId, latitude: data.latitude, longitude: data.longitude)
            } else {
                print("上傳目擊事件失敗")
            }
        }
    }
    
    func didTabWatched(_ sender: TitleTableViewCell) {
        print("看到")
        guard let token = KeychainWrapper.standard.string(forKey: "token"), let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let eventId = self.eventID, let model = self.model, let data = self.data else { return }
        APIManager.postWitness(eventId: eventId, accountId: accountId, token: token, isWitness: 1) { bool in
            if bool{
                print("上傳目擊事件成功")
                model.fetchRangeDangerData(accountId: accountId, latitude: data.latitude, longitude: data.longitude)
            } else {
                print("上傳目擊事件失敗")
            }
        }
    }
    
    func didTabNoWatched(_ sender: TitleTableViewCell) {
        print("沒看到")
        guard let token = KeychainWrapper.standard.string(forKey: "token"), let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let eventId = self.eventID, let model = self.model, let data = self.data else { return }
        APIManager.postWitness(eventId: eventId, accountId: accountId, token: token, isWitness: 2) { bool in
            if bool{
                print("上傳目擊事件成功")
                model.fetchRangeDangerData(accountId: accountId, latitude: data.latitude, longitude: data.longitude)
            } else {
                print("上傳目擊事件失敗")
            }
        }
    }
    
    func didTabImage(_ sender: TitleTableViewCell) {
        print("有案cell圖片")
        //        guard let urlStr = sender.url else { return }
        //        guard let url = URL(string: urlStr) else {
        //            return
        //        }
        //        let safariVC = SFSafariViewController.init(url: url)
        //        self.present(safariVC, animated: true)
    }
    
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var discussTableView: UITableView!
    
    var dataTitle: String?
    var data: DangerousDetailData?
    var messageStr: String?
    var model: DangerousModel?
    //   var index: Int?
    var eventID: String?
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextView.delegate = self
        discussTableView.delegate = self
        discussTableView.dataSource = self
        discussTableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: TitleTableViewCell.reuseIdentifier)
        discussTableView.register(UINib(nibName: "DiscordTableViewCell", bundle: nil), forCellReuseIdentifier: DiscordTableViewCell.reuseIdentifier)
        
        print("討論串的編號：\(String(describing: index))")
        
        inputTextView.layer.cornerRadius = 8
        
        discussTableView.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didPostComment"), object: nil, queue: nil)  {
            noti in
            guard let eventID = self.eventID else { return }
            print("呼叫model fetch留言data")
            self.model?.fetchDiscussionData(eventID: eventID)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didFetchDiscussionData"), object: nil, queue: nil)  {
            noti in
            self.discussTableView.reloadData()
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didFetchDangerData"), object: nil, queue: nil)  {
            noti in
            if let eventID = self.eventID, let model = self.model {
                self.data = model.getData(eventID: eventID)
            }
            
            self.discussTableView.reloadData()
            if let data = self.data{
                print("isWitness:\(data.isWitness)")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let eventID = self.eventID else { return }
        model?.fetchDiscussionData(eventID: eventID)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func clickSendButton(_ sender: UIButton) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let today = dateFormatter.string(from: date)
        print(date)
        print(today)
        //      guard let model = self.model else { return }
        guard let describe = inputTextView.text else { return }
        guard let id = self.eventID else { return }
        guard let token = KeychainWrapper.standard.string(forKey: "token"),let accountId = KeychainWrapper.standard.string(forKey: "accountId") else {
            present(AlertManager.alertView(alertMessage: "登入後才能留言"), animated: true, completion: nil)
            return }
        if describe.count == 0 || describe.elementsEqual("留言......"){
            present(AlertManager.alertView(alertMessage: "請輸入留言"), animated: true, completion: nil)
            return
        }
        print("呼叫api中心post留言")
        APIManager.postComment(eventID: id, accountID: accountId, commentTime: today, comment: describe, token: token)
        
        //       model.addMessage(newMessage: newMessage, index: index)
        inputTextView.text = "留言..."
        inputTextView.textColor = .lightGray
        self.view.endEditing(true)
    }
    
}

extension DiscussViewController: UITableViewDelegate{
    
}

extension DiscussViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = self.model {
            guard let eventID = self.eventID else { return 1}
            print("有幾則留言：\(model.getDiscussCount(eventId: eventID))")
            return model.getDiscussCount(eventId: eventID)+1
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.reuseIdentifier, for: indexPath) as? TitleTableViewCell else{ return UITableViewCell() }
            guard let data = data else { return UITableViewCell() }
            if data.shotLink != nil{
                cell.uploadImage.frame.size = .init(width: 290, height: 245)
            }
            cell.delegate = self
            
            cell.setData(accountId: data.uploaderAccountName, title: data.title, type: data.type, describe: data.description, time: data.uploadTime, locaDetail: data.locationDetails, url: data.shotLink ?? nil, totalWitness: data.totalWitness, totalNoWitness: data.totalNotWitness, isWatched: data.isWitness, uploaderImage: data.uploaderPropicLink)
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DiscordTableViewCell.reuseIdentifier, for: indexPath) as? DiscordTableViewCell else{
                return UITableViewCell()
            }
            guard let model = self.model else { return UITableViewCell() }
            guard let eventID = self.eventID else { return UITableViewCell() }
            print(indexPath.row-1)
            guard let data = model.getMessage(eventID: eventID, index: indexPath.row-1) else { return UITableViewCell() }
            
            cell.setData(name: data.accountName, time: data.commentTime, message: data.comment, userPhotoUrl: data.propicLink)
            
            return cell
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
}

extension DiscussViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.messageStr = textView.text
    }
    
    
}
