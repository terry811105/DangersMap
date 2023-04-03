//
//  DetailInfoViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/14.
//

import UIKit
import GoogleMaps
import Alamofire
import SDWebImage
import SwiftKeychainWrapper

class InputDetailInfoViewController: UIViewController {
    

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleTextfiled: UITextField!
    @IBOutlet weak var describeTextView: UITextView!
    @IBOutlet var options: [UIButton]!
    @IBOutlet var optionsView: [UIView]!
    @IBOutlet weak var locationDescibe: UITextField!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var loadingAc: UIActivityIndicatorView!
    @IBOutlet weak var typeLabel: UILabel!
    
    var detailData: DangerousDetailData?
    
    var dataLocation: CLLocationCoordinate2D?
    
    var model: DangerousModel?
    
    var typeString: String?
    
    var imgUrl: String?
    
    let imagePicker = UIImagePickerController()
    
    var token: String?
    
    var isFirstEdit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingAc.isHidden = true
        loadingAc.style = .large

        eventImage.layer.cornerRadius = 10
        
        imagePicker.delegate = self
        
        titleTextfiled.delegate = self
        locationDescibe.delegate = self
        
        typeView.layer.borderColor = CGColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        typeView.layer.borderWidth = 0.9
        typeView.layer.cornerRadius = 5
        
        describeTextView.delegate = self
        describeTextView.layer.borderColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        describeTextView.layer.borderWidth = 1
        describeTextView.layer.cornerRadius = 5
        
        returnButton.layer.cornerRadius = 15
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap) // to Replace "TouchesBegan"

        
        let tapGetureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didImageTapped(_:)))
        eventImage.isUserInteractionEnabled = true
        eventImage.addGestureRecognizer(tapGetureRecognizer)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @IBAction func clickCameraButton(_ sender: UIButton) {
        self.takePicture()
        
    }
    
    @IBAction func clickPhotoButton(_ sender: UIButton) {
        self.openPhotosAlbum()
        
    }
    
    @objc func didImageTapped(_ tap: UITapGestureRecognizer){
        // 設定跳出視窗內容
        let controller = UIAlertController(title: "選擇圖片", message: "どれ", preferredStyle: .alert)
        controller.view.tintColor = UIColor.gray
        
        // 相機
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            self.takePicture()
        }
        controller.addAction(cameraAction)
        
        // 相薄
        let savedPhotosAlbumAction = UIAlertAction(title: "相簿", style: .default) { _ in
            self.openPhotosAlbum()
        }
        controller.addAction(savedPhotosAlbumAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        controller.addAction(cancelAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectTYpe(_ sender: UIButton) {
        guard let str = sender.titleLabel?.text else { return }
        typeLabel.text = "\(str)"
        typeLabel.textColor = .black
        self.typeString = sender.titleLabel?.text
        for option in optionsView{
            UIView.animate(withDuration: 0.3) {
                option.isHidden = !option.isHidden
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func startSelect(_ sender: UIButton) {
        
        for option in optionsView{
            UIView.animate(withDuration: 0.3) {
                option.isHidden = !option.isHidden
                // 立即更新畫面
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func clickReturnButton(_ sender: Any) {
        guard let title = titleTextfiled.text else {
            present(AlertManager.alertView(alertMessage: "請輸入標題"), animated: true, completion: nil)
            print("沒有標題")
            return }
        guard let type = typeString else {
            present(AlertManager.alertView(alertMessage: "請選擇種類"), animated: true, completion: nil)
            print("沒有種類")
            return }
        guard let location = dataLocation else {
            present(AlertManager.alertView(alertMessage: "沒有位置"), animated: true, completion: nil)
            print("沒有地點")
            return }
        guard let describe = describeTextView.text else {
            present(AlertManager.alertView(alertMessage: "請輸入內容"), animated: true, completion: nil)
            print("沒有內容")
            return }
        
        if loadingAc.isAnimating {
            present(AlertManager.alertView(alertMessage: "請等待圖片上傳"), animated: true, completion: nil)
            return
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let today = dateFormatter.string(from: date)
        //     print(date)
        print(today)
        
        guard let token = KeychainWrapper.standard.string(forKey: "token"),
              let account = KeychainWrapper.standard.string(forKey: "accountId")
        else {
            present(AlertManager.alertView(alertMessage: "登入後才能發布事件"), animated: true, completion: nil)
            print("沒有token")
            return }
        
        
        APIManager.postData(accountId: account, type: type, title: title, longitude: location.longitude, latitude: location.latitude, description: describe, uploadTime: today, shotLink: imgUrl, locationDetails: locationDescibe.text, token: token)
        
        
        // 收掉頁面
        self.dismiss(animated: true, completion: nil)
    }
    
    func setGradientLayer(view: UIView) {
        // 設定漸層顏色
        let color1 =  UIColor(red: 0.681372549, green: 0.8490196078, blue: 0.8896078431, alpha: 0).cgColor
        let color2 =  UIColor(red: 0.9843137255, green: 0.8607843137, blue: 0.7215686275, alpha: 1).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        // color1 為第一個漸層色，color2 為第二個漸層色。
        gradientLayer.colors = [color1, color2]
        // 把 gradientLayer 插入我們的 view 的 Layer 中。
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
}

extension InputDetailInfoViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 要求離開我們的Responder
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.contentView.endEditing(true)
        self.myScrollView.endEditing(true)
    }
}

extension InputDetailInfoViewController: UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = .black
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        if textView.text == "\n" {
            self.view?.endEditing(false)
            return false
        }
        return true
    }
}

extension InputDetailInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    /// 開啟相機
    func takePicture() {
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true)
    }
    
    /// 開啟圖庫
    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    /// 開啟相簿
    func openPhotosAlbum() {
        imagePicker.sourceType = .savedPhotosAlbum
        self.present(imagePicker, animated: true)
    }
    
    // 抓圖片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        loadingAc.isHidden = false
        loadingAc.startAnimating()
        // info 用來取得不同類型的圖片，此 Demo 的型態為 originaImage，其它型態有影片、修改過的圖片等等
        if let image = info[.originalImage] as? UIImage {
            APIManager.uploadImage(uiImage: image) { result in
                switch result{
                case .success(let url):
                    self.imgUrl = url.absoluteString
                    self.eventImage.sd_setImage(with: url, completed: nil)
                    self.loadingAc.stopAnimating()
                    self.loadingAc.isHidden = true
                case .failure(let error):
                    print(error)
                    self.loadingAc.stopAnimating()
                    self.loadingAc.isHidden = true
                }
            }
            //    self.insertPictureToTextView(image: image)
            print("來抓照片")
            
        }
        
        picker.dismiss(animated: true)
    }
    
    func insertPictureToTextView(image: UIImage){
        // 创建附件
        let attachment = NSTextAttachment()
        // 设置附件的大小
        let imageAspectRatio = image.size.height / image.size.width
        let peddingX: CGFloat = 0
        let imageWidth = describeTextView.frame.width - 2 * peddingX
        let imageHeight = imageWidth * imageAspectRatio
        attachment.image = UIImage(data: image.jpegData(compressionQuality: 0.5)!)
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: imageWidth,
                                   height: imageHeight)
        // 将附件转成NSAttributedString类型的属性化文本
        let attImage = NSAttributedString(attachment: attachment)
        // 获取textView的所有文本，转成可变的文本
        let mutableStr = NSMutableAttributedString(attributedString: describeTextView.attributedText)
        // 获得目前光标的位置
        let selectedRange = describeTextView.selectedRange
        // 插入附件
        mutableStr.insert(attImage, at: selectedRange.location)
        mutableStr.insert(NSAttributedString(string: "\n"), at: selectedRange.location+1)
        //        插入图片后另起一行
        //        格式化mutableStr
        //        mutableStr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Noto Sans S Chinese", size: 20)!, range: NSMakeRange(0,mutableStr.length))
        describeTextView.attributedText = mutableStr
    }
    
    
}



