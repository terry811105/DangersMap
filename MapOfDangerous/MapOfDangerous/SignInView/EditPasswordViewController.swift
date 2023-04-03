//
//  EditPasswordViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/31.
//

import UIKit
import SwiftKeychainWrapper

class EditPasswordViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var inputNewPasswordAgainTextField: UITextField!
    @IBOutlet weak var doubleCheckPasswordLebel: UILabel!
    @IBOutlet weak var newPasswordCheckLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        inputNewPasswordAgainTextField.delegate = self
        newPasswordTextField.delegate = self
        oldPasswordTextField.delegate = self
    }
    
    
    @IBAction func clickSaveButton(_ sender: UIButton) {
        if newPasswordTextField.text != inputNewPasswordAgainTextField.text {
            let alertController = UIAlertController(
                title: "請確認密碼",
                message: "輸入兩次不一樣qq",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "確定",
                style: UIAlertAction.Style.default) {
                    (action: UIAlertAction!) -> Void in
                    return
                }
            alertController.addAction(okAction)

            print("輸入兩次不一樣qq")
            self.present(
                alertController,
                animated: true,
                completion: nil)
            return
        }
        
        guard let oldPassword = oldPasswordTextField.text, let newPassword = inputNewPasswordAgainTextField.text, let accountId = KeychainWrapper.standard.string(forKey: "accountId") else {
            return
        }
        
        let oldPasswordMD5 = oldPassword.md5()
        let newPasswordMD5 = newPassword.md5()
        
        APIManager.editMemberPassword(accountId: accountId, oldPW: oldPasswordMD5, newPW: newPasswordMD5, handler: { isSuccess in
            if isSuccess{
                print("修改成功")
                // 建立跳出視窗
                let alertController = UIAlertController(title: "修改成功",
                                                        message: "你好棒",
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
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                print("修改失敗")
            }
            
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
}

extension EditPasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if( textField.tag == 1){
            let theTxtField = self.view?.viewWithTag(2) as? UITextField
            theTxtField?.becomeFirstResponder()
        } else if textField.tag == 2 {
            if oldPasswordTextField.text == newPasswordTextField.text{
                newPasswordCheckLabel.isHidden = false
                newPasswordCheckLabel.text = "與舊密碼重複！"
            } else {
                newPasswordCheckLabel.isHidden = true
            }
            let theTxtField = self.view?.viewWithTag(3) as? UITextField
            theTxtField?.becomeFirstResponder()
        }
        else {
            if newPasswordTextField.text != inputNewPasswordAgainTextField.text {
                doubleCheckPasswordLebel.isHidden = false
                doubleCheckPasswordLebel.text = "確認密碼與新密碼不符"
            } else {
                doubleCheckPasswordLebel.isHidden = true
            }
            self.view.endEditing(true)
        }
        return true
    }
}
