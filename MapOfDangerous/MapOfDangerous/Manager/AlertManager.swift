//
//  AlertManager.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2022/1/4.
//

import Foundation
import UIKit

class AlertManager{
    
    static func alertView(alertMessage: String) -> UIAlertController{
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
        return alertController
    }
}
