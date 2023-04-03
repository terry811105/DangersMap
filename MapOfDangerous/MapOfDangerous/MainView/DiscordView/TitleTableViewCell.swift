//
//  TitleTableViewCell.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/17.
//

import UIKit
import SDWebImage
import WebKit
import SafariServices
import SwiftKeychainWrapper

protocol TitleTableViewCellDelegate: AnyObject{
    func didTabImage(_ sender: TitleTableViewCell)
    
    func didTabWatched(_ sender: TitleTableViewCell)
    
    func didTabNoWatched(_ sender: TitleTableViewCell)
    
    func didNothing(_ sender: TitleTableViewCell)
    
    func needToLogIn(_ sender: TitleTableViewCell)
}


class TitleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TitleTableViewCell"
    
    weak var delegate: TitleTableViewCellDelegate? = nil
    
    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var noWatchedCount: UILabel!
    @IBOutlet weak var watchedCount: UILabel!
    @IBOutlet weak var neverWatchedbutton: UIButton!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var locationDetail: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var uploadTime: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var describeLabel: UILabel!
    
    var distanceX = 114.5
    var distanceY = 17.879310344827587
    
    @IBOutlet weak var postView: UIView!
    
    var url: String?
    
    var isTap: Bool = false
    
    var isSetImage: Bool = false
    var isClickWatched: Bool = false
    var isClickNeverWatched: Bool = false
    
    var newImage: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = 17.5
        
        let tapGetureRecognizerOfEventImage = UITapGestureRecognizer(target: self, action: #selector(didTappedEventImage(_:)))
        uploadImage.isUserInteractionEnabled = true
        uploadImage.addGestureRecognizer(tapGetureRecognizerOfEventImage)
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func checkValidation() -> Bool{
        var isValidation = false
        if let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let token = KeychainWrapper.standard.string(forKey: "token"){
            APIManager.getMemberInfo(accountId: accountId, token: token) { result in
                switch result{
                case .success(let memberData):
                    print("")
                    if memberData.validation{
                        isValidation =  true
                    } else {
                        isValidation = false
                    }
                case .failure(_):
                    print("")
                    isValidation = false
                }
            }
        } else {
            isValidation = false
        }
        return isValidation
    }
    
    @IBAction func clickWatched(_ sender: UIButton) {
        guard let accountId = KeychainWrapper.standard.string(forKey: "accountId") else {
            self.delegate?.needToLogIn(self)
            return }
//        if !checkValidation(){
//            self.delegate?.needToLogIn(self)
//            return
//        }
        
        isClickWatched = !isClickWatched
        if isClickWatched && isClickNeverWatched{
            //        print("沒看到的按鈕應該要變灰色")
            isClickNeverWatched = false
            neverWatchedbutton.tintColor = .lightGray
            
        }
        //     print("按下看到 clickWatch:\(isClickWatched),  noWatch:\(isClickNeverWatched)")
        
        if isClickWatched{
            sender.tintColor = .tintColor
            self.delegate?.didTabWatched(self)
        } else {
            self.delegate?.didNothing(self)
            sender.tintColor = .lightGray
        }
        
    }
    
    @IBAction func clickNeverWatch(_ sender: UIButton) {
                guard let accountId = KeychainWrapper.standard.string(forKey: "accountId") else {
                    self.delegate?.needToLogIn(self)
                    return }
//        if !checkValidation(){
//            self.delegate?.needToLogIn(self)
//            return
//        }
        
        isClickNeverWatched = !isClickNeverWatched
        
        //   print("按下沒看到 clickNoWatch:\(isClickWatched),  noWatch:\(isClickNeverWatched)")
        
        if isClickNeverWatched && isClickWatched{
            //         print("看到的按鈕應該要變灰色")
            isClickWatched = false
            watchedButton.tintColor = .lightGray
        }
        
        if isClickNeverWatched{
            sender.tintColor = .tintColor
            self.delegate?.didTabNoWatched(self)
        } else {
            self.delegate?.didNothing(self)
            sender.tintColor = .lightGray
        }
    }
    
    @objc func didTappedEventImage(_ tap: UITapGestureRecognizer){
        self.delegate?.didTabImage(self)
        print("有按圖片")
        isTap = !isTap
//        bigImage.image = uploadImage.image
//        bigImage.isHidden = !bigImage.isHidden
        //        guard let img = newImage else { return }
        //        img.image = uploadImage.image
//                if isTap{
//
//                    bigImage.isHidden = false
//
//                } else {
//
//                    bigImage.isHidden = true
//                }
        print("UIScreen.main.bounds.minX: \(UIScreen.main.bounds.minX)")
        print("UIScreen.main.bounds.minY: \(UIScreen.main.bounds.minY)")
        
        print("uploadImage.frame.minX: \(uploadImage.frame.minX)")
        print("uploadImage.frame.minY: \(uploadImage.frame.minY)")
        
//        let scale = UIScreen.main.bounds.width / uploadImage.frame.width
//        distanceX = -distanceX
//        distanceY = -distanceY
//        AnimatorManager.shared.zoomIn(view: uploadImage, scale: scale, distanceX: -uploadImage.frame.minX, distanceY: -uploadImage.frame.minY)
        
    }
    
    func setData(accountId: String, title: String, type: String, describe: String, time: String, locaDetail: String?, url: String?, totalWitness: Int, totalNoWitness: Int, isWatched: Int, uploaderImage: String){
        userName.text = accountId
        titleLabel.text = title
        typeLabel.text = type
        describeLabel.text = describe
        if let locaDetail = locaDetail {
            locationDetail.isHidden = false
            locationDetail.text = locaDetail
        }
        print("目擊次數：\(totalWitness)，沒目擊次數：\(totalNoWitness)")
        watchedCount.text = String(totalWitness)
        
        noWatchedCount.text = String(totalNoWitness)
        
        uploadTime.text = time
        
        print("isWatched:\(isWatched)")
        
        if isWatched == 1 {
            watchedButton.tintColor = .tintColor
            self.isClickWatched = true
        }
        if isWatched == 2 {
            neverWatchedbutton.tintColor = .tintColor
            self.isClickNeverWatched = true
        }
        
        let uploaderUrl = URL(string: uploaderImage)
        userPhoto.sd_setImage(with: uploaderUrl, placeholderImage: UIImage(systemName: "person"))
        
        if let url = url {
            self.url = url
            let imageUrl = URL(string: url)
            uploadImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "photo"))
            uploadImage.isHidden = false
            
//            newImage = .init(image: uploadImage.image)
//
//            if let newImage = newImage {
//
//                newImage.frame = self.frame
//                newImage.contentMode = .scaleAspectFit
//                self.addSubview(newImage)
//                newImage.isHidden = true
//
//
//            }
            
            
        } else {
            uploadImage.isHidden = false
            uploadImage.alpha = 0.3
            noImageLabel.isHidden = false
            
            
        }
        
    }
    
}
