//
//  SignUpViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/27.
//

import UIKit
import CryptoKit
import SwiftKeychainWrapper

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var accStackView: UIStackView!
    @IBOutlet weak var cView: UIView!
    @IBOutlet weak var signUPScrollView: UIScrollView!
    @IBOutlet weak var passwordSame: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var inputEmailTextField: UITextField!
    @IBOutlet weak var inputAccountTextFiled: UITextField!
    @IBOutlet weak var inputPasswordTextField: UITextField!
    @IBOutlet weak var inputPasswordAgainTextField: UITextField!
    @IBOutlet weak var inputNickNameTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    var isSettingPhoto = false
    
    var photoUrl: String?
    
    var isPasswordSame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordSame.isHidden = true
        loadingActivity.isHidden = true
        sendButton.layer.cornerRadius = 15
        imagePicker.delegate = self
        inputAccountTextFiled.delegate = self
        inputEmailTextField.delegate = self
        inputPasswordTextField.delegate = self
        inputPasswordAgainTextField.delegate = self
        inputNickNameTextField.delegate = self
        
        let tapGetureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didImageTapped(_:)))
        userPhotoImageView.isUserInteractionEnabled = true
        userPhotoImageView.addGestureRecognizer(tapGetureRecognizer)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap) // to Replace "TouchesBegan"
        
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    // 點擊事件：設定頭貼
    @objc func didImageTapped(_ tap: UITapGestureRecognizer){
        // 設定跳出視窗內容
        let controller = UIAlertController(title: "設置大頭貼", message: "", preferredStyle: .alert)
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
    
    /// 送出註冊
    @IBAction func clickSendButton(_ sender: UIButton) {

        guard let account = inputAccountTextFiled.text else {
            alertView(alertMessage: "請輸入帳號")
            return }
        guard let password = inputPasswordTextField.text else {
            alertView(alertMessage: "請輸入密碼")
            return }
        guard let passwordAgain = inputPasswordAgainTextField.text else {
            alertView(alertMessage: "請確認密碼")
            return
        }
        guard let email = inputEmailTextField.text else {
            alertView(alertMessage: "請輸入email")
            return }
        guard let nickName = inputNickNameTextField.text else {
            alertView(alertMessage: "請輸入暱稱")
            return }
        guard let photoUrl = photoUrl else {
            alertView(alertMessage: "請設置頭貼")
            
            return }

        if !validateEmail(email: email){
            alertView(alertMessage: "請輸入正確的信箱")
        }
        
        if account.count < 6 {
            alertView(alertMessage: "帳號請大於6個字")
            return
        }
        
        if password.count < 8 {
            alertView(alertMessage: "密碼請設置8-12個英文、數字、底線")
        }
        
        if passwordAgain != password {
            alertView(alertMessage: "請輸入相同的密碼")
        }
        
        if nickName.count == 0 {
            alertView(alertMessage: "請輸入暱稱")
        }

        let passwordMD5 = password.md5()
        
        APIManager.signUp(accountId: account, password: passwordMD5, accountName: nickName, accountEmail: email, propicLink: photoUrl){ result in
            switch result{
            case .success(let str):
                print(str)
                APIManager.logIn(account: account, password: passwordMD5) {
                    result in
                    switch result{
                    case .success(_):
                        // print(str)
                        // 建立跳出視窗
                        
                        if KeychainWrapper.standard.set(str, forKey: "token"){
                            print("成功紀錄token到keychain")
                        }
                        
                        if KeychainWrapper.standard.set(account, forKey: "accountId"){
                            print("成功紀錄accountId到keychain")
                        }

                    case .failure(let error):
                        print(error)
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
        // 建立跳出視窗
        let alertController = UIAlertController(title: "註冊成功",
                                                message: "請去信箱收驗證信",
                                                preferredStyle: UIAlertController.Style.alert)
        // 建立送出按鈕
        let sendBtn = UIAlertAction(
            title: "ok",
            style: UIAlertAction.Style.default)
        {(UIAlertAction) in
            
            
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(sendBtn)
        // 顯示提示框
        present(alertController, animated: true, completion: nil)
    }
    
    func alertView(alertMessage: String){
        // 建立跳出視窗
        let alertController = UIAlertController(title: alertMessage,
                                                message: "",
                                                preferredStyle: UIAlertController.Style.alert)
        // 建立送出按鈕
        let sendBtn = UIAlertAction(
            title: "確定",
            style: UIAlertAction.Style.default)
        {(UIAlertAction) in
            return
        }
        alertController.addAction(sendBtn)
        // 顯示提示框
        present(alertController, animated: true, completion: nil)
    }
    
    // 驗證郵箱的正則表達式，網路查的
    func validateEmail(email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

}

extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if( textField.tag == 1){
            let theTxtField = self.view?.viewWithTag(2) as? UITextField
            theTxtField?.becomeFirstResponder()
        } else if textField.tag == 2 {
            let theTxtField = self.view?.viewWithTag(3) as? UITextField
            theTxtField?.becomeFirstResponder()
        } else if textField.tag == 3 {
            let theTxtField = self.view?.viewWithTag(4) as? UITextField
            theTxtField?.becomeFirstResponder()
        } else if textField.tag == 4 {
            guard let password = inputPasswordTextField.text else { return false }
            guard let passwordAgain = inputPasswordAgainTextField.text else { return false }
            if !password.elementsEqual(passwordAgain){
                passwordSame.text = "密碼不一樣"
                passwordSame.isHidden = false
                isPasswordSame = false
            } else {
                passwordSame.isHidden = true
                isPasswordSame = true
            }
            let theTxtField = self.view?.viewWithTag(5) as? UITextField
            theTxtField?.becomeFirstResponder()
        }
        else{
            
            self.view.endEditing(true)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.signUPScrollView.endEditing(true)
        self.cView.endEditing(true)
        
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
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
            self.userPhotoImageView.image = image
            print("來抓照片")
            self.isSettingPhoto = true
            APIManager.uploadImage(uiImage: image) {
                result in
                switch result{
                case .success(let url):
                    print(url)
                    self.photoUrl = url.absoluteString
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



extension String {
    func md5() -> String {
        return Insecure.MD5.hash(data: self.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }
}
