//
//  SignInViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/27.
//

import UIKit
import CryptoKit
import SDWebImage
import SwiftKeychainWrapper

class SignInViewController: UIViewController {
    
    @IBOutlet weak var noValidationLabel: UILabel!
    @IBOutlet var labelContentView: [UIView]!
    @IBOutlet weak var userPhotoFrame: UIView!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var editNickNameButton: UIButton!
    @IBOutlet weak var accountIdLabel: UILabel!
    @IBOutlet weak var editPasswordButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var inputAccountTextFiled: UITextField!
    @IBOutlet weak var inputPasswordTextFiled: UITextField!
    
    let imagePicker = UIImagePickerController()
    var propicLink: String?
    var nickName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in labelContentView {
            item.layer.cornerRadius = 10
        }
        userPhotoFrame.layer.cornerRadius = 80
        loadingActivity.isHidden = true
        imagePicker.delegate = self
        editPhotoButton.layer.cornerRadius = 12.5
//        editPhotoButton.layer.borderWidth = 2.5
//        editPhotoButton.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        editNickNameButton.layer.cornerRadius = 12.5
//        editNickNameButton.layer.borderWidth = 2.5
//        editNickNameButton.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        if let account = KeychainWrapper.standard.string(forKey: "accountId"), let token = KeychainWrapper.standard.string(forKey: "token") {
            APIManager.getMemberInfo(accountId: account, token: token){ result in
                switch result{
                case .success(let memberData):
                    print("拿到會員資料")
                    if !memberData.validation{
                        self.noValidationLabel.isHidden = false
                    } else {
                        self.noValidationLabel.isHidden = true
                    }
                    self.userName.text = memberData.accountName
                    self.nickName = memberData.accountName
                    self.accountIdLabel.text = account
                    self.propicLink = memberData.propicLink
                    let url = URL(string: memberData.propicLink)
                    self.userPhoto.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
                    self.memberView.isHidden = false
                case .failure(let error):
                    print(error)
                }
                
            }
        }
        
        userPhoto.layer.cornerRadius = 75
        inputAccountTextFiled.delegate = self
        inputPasswordTextFiled.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("登入頁出現")
        inputAccountTextFiled.text = nil
        inputPasswordTextFiled.text = nil
        if let account = KeychainWrapper.standard.string(forKey: "accountId"), let token = KeychainWrapper.standard.string(forKey: "token") {
            APIManager.getMemberInfo(accountId: account, token: token){ result in
                switch result{
                case .success(let memberData):
                    print("拿到會員資料")
                    if !memberData.validation{
                        self.noValidationLabel.isHidden = false
                    } else {
                        self.noValidationLabel.isHidden = true
                    }
                    self.userName.text = memberData.accountName
                    self.nickName = memberData.accountName
                    self.accountIdLabel.text = account
                    self.propicLink = memberData.propicLink
                    let url = URL(string: memberData.propicLink)
                    self.userPhoto.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
                    self.memberView.isHidden = false
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("登入頁消失")
    }
    
    @IBAction func clickEditPasswordButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "EditPasswordViewController", bundle: .main)
        if let editPasswordVC = storyboard.instantiateViewController(withIdentifier: "EditPasswordViewController") as? EditPasswordViewController{
            
            self.navigationController?.pushViewController(editPasswordVC, animated: true)
        }
    }
    
    @IBAction func clickEditPhoto(_ sender: Any) {
        editPhoto()
    }
    
    @IBAction func clickEditNickNameButton(_ sender: UIButton) {
        editNickName()
    }
    
    func editNickName() {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "修改暱稱",
            message: "請輸入暱稱：",
            preferredStyle: .alert)
        
        // 建立一個輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "請輸入新暱稱..."
        }
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[確定]按鈕
        let okAction = UIAlertAction(
            title: "確定",
            style: UIAlertAction.Style.default) {
                (action: UIAlertAction!) -> Void in
                let acc =
                (alertController.textFields?.first)!
                as UITextField
                
                guard let propicLink = self.propicLink, let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let nickName = acc.text else {
                    return
                }

                APIManager.editMemberData(accountId: accountId, accountName: nickName, propicLink: propicLink){ isSuccess in
                    if isSuccess{
                        print("修改成功")
                        self.userName.text = nickName
                    } else {
                        print("修改失敗")
                    }
                    
                }
                print("輸入的帳號為：\(String(describing: acc.text))")
                
            }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func forgetPassword(){
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "忘記密碼",
            message: "請輸入帳號：",
            preferredStyle: .alert)
        
        // 建立一個輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "請輸入帳號..."
        }
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[確定]按鈕
        let okAction = UIAlertAction(
            title: "確定",
            style: UIAlertAction.Style.default) {
                (action: UIAlertAction!) -> Void in
                let acc =
                (alertController.textFields?.first)!
                as UITextField
                
                guard let accountId = acc.text else {
                    return
                }

                APIManager.forgetPassword(accountId: accountId){ isSuccess in
                    if isSuccess{
                        print("修改成功，忘記密碼")
                        self.present(AlertManager.alertView(alertMessage: "修改成功，請去信箱收信"), animated: true, completion: nil)
                    } else {
                        print("修改失敗，忘記密碼")
                    }
                    
                }
                print("輸入的帳號為：\(String(describing: acc.text))")
                
            }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func editPhoto(){
        // 設定跳出視窗內容
        let controller = UIAlertController(title: "編輯大頭貼", message: "請選擇", preferredStyle: .alert)
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
    
    @IBAction func clickSignUpButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SignUpViewController", bundle: .main)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController{
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
    @IBAction func clickLogInButton(_ sender: UIButton) {
        guard let account = inputAccountTextFiled.text else { return }
        guard let password = inputPasswordTextFiled.text else { return }
        
        let passwordMD5 = password.md5()
        APIManager.logIn(account: account, password: passwordMD5){
            result in
            
            switch result{
            case .success(let str):
                // print(str)
                // 建立跳出視窗
                if(str.count != 3){
                    if KeychainWrapper.standard.set(str, forKey: "token"){
                        print("成功紀錄token到keychain")
                        
                    }
                    
                    if KeychainWrapper.standard.set(account, forKey: "accountId"){
                        print("成功紀錄accountId到keychain")
                    }
                    
                    let alertController = UIAlertController(title: "登入成功",
                                                            message: "",
                                                            preferredStyle: UIAlertController.Style.alert)
                    // 建立送出按鈕
                    let sendBtn = UIAlertAction(
                        title: "ok",
                        style: UIAlertAction.Style.default)
                    {(UIAlertAction) in
                        APIManager.getMemberInfo(accountId: account, token: str){ result in
                            switch result{
                            case .success(let memberData):
                                print("拿到會員資料")
                                if !memberData.validation{
                                    self.noValidationLabel.isHidden = false
                                } else {
                                    self.noValidationLabel.isHidden = true
                                }
                                self.userName.text = memberData.accountName
                                let url = URL(string: memberData.propicLink)
                                self.userPhoto.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
                                self.memberView.isHidden = false
                                self.tabBarController?.selectedIndex = 0
                            case .failure(let error):
                                print(error)
                            }
                            
                        }
                        
                    }
                    alertController.addAction(sendBtn)
                    // 顯示提示框
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "登入失敗",
                                                            message: "",
                                                            preferredStyle: UIAlertController.Style.alert)
                    // 建立送出按鈕
                    let sendBtn = UIAlertAction(
                        title: "ok",
                        style: UIAlertAction.Style.default)
                    
                    alertController.addAction(sendBtn)
                    // 顯示提示框
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func clickForgetPassword(_ sender: UIButton) {
        forgetPassword()
    }
    
    
    @IBAction func clickLogOutButton(_ sender: UIButton) {
        APIManager.logout{ isSuccess in
            if isSuccess{
                self.memberView.isHidden = true
                self.inputAccountTextFiled.text = nil
                self.inputPasswordTextFiled.text = nil
            } else {
                print("登出失敗")
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
}

extension SignInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if( textField.tag == 1){
            let theTxtField = self.view?.viewWithTag(2) as? UITextField
            theTxtField?.becomeFirstResponder()
        }
        else{
            self.view.endEditing(true)
        }
        return true
    }
}

extension SignInViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
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
        loadingActivity.isHidden = false
        loadingActivity.startAnimating()
        // info 用來取得不同類型的圖片，此 Demo 的型態為 originaImage，其它型態有影片、修改過的圖片等等
        if let image = info[.originalImage] as? UIImage {
            print("來抓照片")
            APIManager.uploadImage(uiImage: image) {
                result in
                switch result{
                case .success(let url):
                    print(url)
                    
                    let propicLink = url.absoluteString
                    guard let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let nickName = self.nickName else {
                        return
                    }

                    APIManager.editMemberData(accountId: accountId, accountName: nickName, propicLink: propicLink){ isSuccess in
                        if isSuccess{
                            self.userPhoto.sd_setImage(with: url, completed: nil)
                            print("修改image成功")
                        } else {
                            print("修改image失敗")
                        }
                        
                    }
                    self.loadingActivity.stopAnimating()
                    self.loadingActivity.isHidden = true
                case .failure(let error):
                    print(error)
                    self.loadingActivity.stopAnimating()
                    self.loadingActivity.isHidden = true
                }
            }
            
        }
        
        picker.dismiss(animated: true)
    }
}
