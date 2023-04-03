//
//  APIManager.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/19.
//

import Foundation
import UIKit
import Alamofire
import SwiftKeychainWrapper


class APIManager {
    
    static func uploadImage(uiImage: UIImage, handler: @escaping (Result<URL, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID e66ef93e7e9597a"
        ]
        
        AF.upload(multipartFormData: { (data) in
            let imageData = uiImage.jpegData(compressionQuality: 0.9)
            data.append(imageData!, withName: "image")
            
        }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: UploadImageResult.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let result):
                print(result.data.link)
                print("上傳成功")
                handler(.success(result.data.link))
                
                
            case .failure(let error):
                print(error)
                handler(.failure(error))
            }
        }
    }
    
    static func getDangerousData(handler: @escaping (Result<[DangerousDetailData], Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Instant/AllEvent") else { return }
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("失敗-資料為空 - getDangerousData ")
                    return
                }
                guard let object = try? JSONDecoder().decode([DangerousDetailData].self, from: data) else {
                    print("失敗-轉換物件錯誤 alldanger")
                    return
                }
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)")
                handler(.failure(error))
            }
        }
    }
    
    static func getRangeDangerDataWithId(accountId: String, latitude: Double, longitude: Double, handler: @escaping (Result<[DangerousDetailData], Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Instant/RangeEvent/\(accountId)?longitude=\(longitude)&latitude=\(latitude)") else { return }
        
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    let noDataArray: [DangerousDetailData] = []
                    handler(.success(noDataArray))
                    print("失敗-資料為空 - 特定範圍事件with id")
                    return
                }
                guard let object = try? JSONDecoder().decode([DangerousDetailData].self, from: data) else {
                    print("失敗-轉換物件錯誤 - 特定範圍事件with id")
                    return
                }
                
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)- 特定範圍事件")
                handler(.failure(error))
            }
        }
    }
    
    static func getRangeDangerData(latitude: Double, longitude: Double, handler: @escaping (Result<[DangerousDetailData], Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Instant/RangeEvent?longitude=\(longitude)&latitude=\(latitude)") else { return }
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    let noDataArray: [DangerousDetailData] = []
                    handler(.success(noDataArray))
                    print("失敗-資料為空 - 特定範圍事件")
                    return
                }
                guard let object = try? JSONDecoder().decode([DangerousDetailData].self, from: data) else {
                    print("失敗-轉換物件錯誤 - 特定範圍事件")
                    return
                }
                
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)- 特定範圍事件")
                handler(.failure(error))
            }
        }
        
    }
    
    static func getDiscussionData(eventID: String, handler: @escaping (Result<[DiscussMessageData], Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Discussion/\(eventID)") else { return }
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("失敗-資料為空 留言")
                    return
                }
                guard let object = try? JSONDecoder().decode([DiscussMessageData].self, from: data) else {
                    print("失敗-轉換物件錯誤 discussion")
                    return
                }
                print("成功")
                print(object)
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)")
                handler(.failure(error))
            }
        }
    }
    
    static func getTrafficAccidentData(latitude: Double, longitude: Double, handler: @escaping (Result<[CarAccidentData], Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/NotInstant/TrafficAccident?longitude=\(longitude)&latitude=\(latitude)") else { return }
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("失敗-資料為空 - 特定範圍車禍事件")
                    return
                }
                guard let object = try? JSONDecoder().decode([CarAccidentData].self, from: data) else {
                    print("失敗-轉換物件錯誤 - 特定範圍車禍事件")
                    return
                }
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)- 特定範圍車禍事件")
                handler(.failure(error))
            }
        }
    }
    
    static func getCriminalIncidentData(latitude: Double, longitude: Double, handler: @escaping (Result<CriminalIncidentData, Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/NotInstant/CriminalIncident?longitude=\(longitude)&latitude=\(latitude)") else { return }
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("失敗-資料為空 - 特定範圍犯罪事件")
                    let noDataArray = CriminalIncidentData(district: "no data", snatch: 0, rape: 0, rob: 0, carTheft: 0, scooterTheft: 0, drug: 0, houseTheft: 0)
                    handler(.success(noDataArray))
                    return
                }
                guard let object = try? JSONDecoder().decode(CriminalIncidentData.self, from: data) else {
                    print("失敗-轉換物件錯誤 - 特定範圍犯罪事件")
                    return
                }
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)- 特定範圍犯罪事件")
                handler(.failure(error))
            }
        }
    }
    
    static func postData(accountId: String, type: String, title: String, longitude: Double, latitude: Double, description: String, uploadTime: String, shotLink: String?, locationDetails: String?, token: String){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Instant/Event") else { return }
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        let params = [
            "accountId": accountId,
            "type": type,
            "title": title,
            "description": description,
            "longitude": longitude,
            "latitude": latitude,
            "locationDetails": locationDetails ?? "地點描述",
            "uploadTime": uploadTime,
            "shotLink": shotLink ?? nil
        ] as [String: Any]
        
        print(params)
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: myHeaders).response { re in
            if re.error != nil {
                print("上傳事件失敗，無法取得回傳資料")
            }
            let statusCode = re.response?.statusCode
            switch statusCode{
            case 200:
                print("上傳成功")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPostData"), object: nil)
            case 401:
                print("token失效")
                refreshToken(account: accountId, token: token) {
                    re in
                    switch re{
                    case .success(let token):
                        if KeychainWrapper.standard.removeObject(forKey: "token"){
                            print("刪掉舊token")
                            if KeychainWrapper.standard.set(token, forKey: "token"){
                                print("重新refresh token")
                                //        postData(accountId: accountId, type: type, title: title, longitude: longitude, latitude: latitude, description: description, uploadTime: uploadTime, shotLink: shotLink, locationDetails: locationDetails, token: token)
                            }
                        }
                    case .failure(_):
                        print("")
                    }
                }
            default:
                print("錯誤\(String(describing: statusCode))")
                
            }
            
        }
    }
    
    static func postComment(eventID: String, accountID: String, commentTime: String, comment: String, token: String){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Discussion") else { return }
        
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let params = [
            "eventId": eventID,
            "accountId": accountID,
            "commentTime": commentTime,
            "comment": comment
        ] as [String: Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: myHeaders).response { re in
            if re.error != nil {
                print("上傳事件失敗，無法取得回傳資料")
            }
            let statusCode = re.response?.statusCode
            switch statusCode{
            case 200:
                print("上傳成功")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPostComment"), object: nil)
            case 401:
                print("token失效")
                refreshToken(account: accountID, token: token) {
                    re in
                    switch re{
                    case .success(let token):
                        if KeychainWrapper.standard.removeObject(forKey: "token"){
                            print("刪掉舊token")
                            if KeychainWrapper.standard.set(token, forKey: "token"){
                                print("重新refresh token")
                                //          postComment(eventID: eventID, accountID: accountID, commentTime: commentTime, comment: comment, token: token)
                            }
                        }
                    case .failure(_):
                        print("")
                    }
                }
            default:
                print("錯誤\(String(describing: statusCode))")
                
            }
            
        }
    }
    
    static func signUp(accountId: String, password: String, accountName: String, accountEmail: String, propicLink: String, handler: @escaping (Result<String, Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/Register") else { return }
        
        let params = [
            "accountId": accountId,
            "password": password,
            "accountName": accountName,
            "accountEmail": accountEmail,
            "propicLink": propicLink
        ] as [String: Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response {
            response in
            print("註冊statusCode:\(String(describing: response.response?.statusCode))")
            let statusCode = response.response?.statusCode
            if statusCode == 200{
                email(accountId: accountId) { bool in
                    if bool{
                        print("驗證信寄出")
                    }else{
                        print("驗證信失敗")
                    }
                    
                }
            }
            
            switch response.result {
            case .success(let data):
                print("data:\(String(describing: data))")
                if let data = data {
                    let tokon = String(data: data, encoding: .utf8) ?? ""
                    print("註冊有成功嗎\(tokon)")
                    
                    handler(.success(tokon))
                } else {
                    logIn(account: accountId, password: password) {
                        result in
                        switch result{
                        case .success(let str):
                            // print(str)
                            // 建立跳出視窗
                            if str.count > 4 {
                                if KeychainWrapper.standard.set(str, forKey: "token"){
                                    print("成功紀錄token到keychain")
                                }
                                
                                if KeychainWrapper.standard.set(accountId, forKey: "accountId"){
                                    print("成功紀錄accountId到keychain")
                                }
                            }
                            
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                    }
                    print("沒有data")
                }
            case .failure(let error):
                print("錯誤\(error)")
                handler(.failure(error))
            }
        }
    }
    
    static func email(accountId: String, handler: @escaping (Bool) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/Mail/\(accountId)") else { return }
        
        AF.request(url).response {
            response in
            let statusCode = response.response?.statusCode
            switch statusCode {
            case 200:
                print("驗證信成功寄出...嗎")
                handler(true)
                
            default :
                print("錯誤")
                handler(false)
            }
        }
    }
    
    static func logIn(account: String, password: String, handler: @escaping (Result<String, Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/Login") else { return }
        
        let params = [
            "accountId": account,
            "password": password
        ] as [String: Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response {
            response in
            
            guard let statusCode = response.response?.statusCode else {
                return
            }
            
            switch response.result {
            case .success(let data):
                if let data = data {
                    let tokon = String(data: data, encoding: .utf8) ?? ""
                    
                    if statusCode != 200 {
                        handler(.success(String(statusCode)))
                    } else {
                        print("token:\(tokon)")
                        handler(.success(tokon))
                    }
                    
                }
                
            case .failure(let error):
                print("錯誤\(error)")
                handler(.failure(error))
            }
        }
    }
    
    static func logout(handler: @escaping (Bool) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/Logout") else { return }
        
        guard let token = KeychainWrapper.standard.string(forKey: "token"),let accountId = KeychainWrapper.standard.string(forKey: "accountId") else { return }
        
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let params = [
            "accountId": accountId
        ] as [String: Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: myHeaders).response {
            response in
            let statusCode = response.response?.statusCode
            switch statusCode{
            case 200:
                if KeychainWrapper.standard.removeObject(forKey: "token") && KeychainWrapper.standard.removeObject(forKey: "accountId"){
                    print("登出成功")
                    handler(true)
                } else {
                    print("keychain沒有刪掉")
                    handler(false)
                }
                
            default:
                print("錯誤\(String(describing: statusCode))")
                handler(false)
            }
        }
    }
    
    static func getRangeDangerDataByMeters(meters: Int, latitude: Double, longitude: Double, handler: @escaping ([DangerousDetailData]) -> Void){
        
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Instant/OptionalRangeEvent/\(meters)?longitude=\(longitude)&latitude=\(latitude)") else { return }
        
        AF.request(url).response {
            response in
            
            guard let statusCode = response.response?.statusCode else {
                return
            }
            
            switch statusCode{
            case 200:
                print("成功")
                guard let data = response.data else {
                    let noDataArray: [DangerousDetailData] = []
                    handler(noDataArray)
                    print("失敗-資料為空 - 特定範圍事件")
                    return
                }
                guard let object = try? JSONDecoder().decode([DangerousDetailData].self, from: data) else {
                    let noDataArray: [DangerousDetailData] = []
                    handler(noDataArray)
                    print("失敗-轉換物件錯誤 - 特定範圍事件")
                    return
                }
                
                handler(object)
            case 204:
                let noDataArray: [DangerousDetailData] = []
                handler(noDataArray)
                print("無事件")
                
            default:
                let noDataArray: [DangerousDetailData] = []
                handler(noDataArray)
                print("失敗")
                
            }
        }
    }
    
    static func forgetPassword(accountId: String, handler: @escaping (Bool) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/PasswordMail") else { return }
        
        let params = [
            "accountId": accountId
        ] as [String: Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response { re in
            if re.error != nil {
                print("忘記密碼失敗，無法取得回傳資料")
            }
            let statusCode = re.response?.statusCode
            switch statusCode{
            case 200:
                print("忘記密碼成功，送出驗證信")
                handler(true)
            case 404:
                print("查無此id")
                handler(false)
            default:
                print("錯誤\(String(describing: statusCode))")
                handler(false)
                
            }
            
        }
    }
    
    static func getMemberInfo(accountId: String,token: String, handler: @escaping (Result<MemberData, Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/\(accountId)") else { return }
        
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, headers: myHeaders).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("失敗-資料為空 - 會員資料")
                    return
                }
                guard let object = try? JSONDecoder().decode(MemberData.self, from: data) else {
                    print("失敗-轉換物件錯誤 - 會員資料")
                    return
                }
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)- 會員資料")
                handler(.failure(error))
            }
        }
    }
    
    static func editMemberData(accountId: String, accountName: String, propicLink: String, handler: @escaping (Bool) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/Edit/Account/\(accountId)") else { return }
        
        guard let token = KeychainWrapper.standard.string(forKey: "token") else { return }
        
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let params = [
            "accountName": accountName,
            "propicLink": propicLink
        ] as [String: Any]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: myHeaders).response {
            response in
            let statusCode = response.response?.statusCode
            switch statusCode{
            case 200:
                print("更改成功")
                handler(true)
            case 204:
                print("查無此人")
                handler(false)
            default:
                print("錯誤\(String(describing: statusCode))")
                handler(false)
            }
        }
        
    }
    
    static func editMemberPassword(accountId: String, oldPW: String, newPW: String, handler: @escaping (Bool) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/Edit/Password/\(accountId)") else { return }
        
        guard let token = KeychainWrapper.standard.string(forKey: "token") else { return }
        
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let params = [
            "oldPassword": oldPW,
            "newPassword": newPW
        ] as [String: Any]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: myHeaders).response {
            response in
            let statusCode = response.response?.statusCode
            switch statusCode{
            case 200:
                print("更改成功")
                handler(true)
            case 204:
                print("查無此人")
                handler(false)
            default:
                print("錯誤\(String(describing: statusCode))")
                handler(false)
            }
        }
    }
    
    static func getNewsTicker(handler: @escaping (Result<[NewsTickerData], Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/NewsTicker") else { return }
        AF.request(url).response {
            response in
            switch response.result {
            case .success(let data):
                guard let data = data else {
                    print("失敗-資料為空 - 跑馬燈")
                    return
                }
                guard let object = try? JSONDecoder().decode([NewsTickerData].self, from: data) else {
                    print("失敗-轉換物件錯誤 跑馬燈")
                    return
                }
                //     print("成功-\(object)")
                handler(.success(object))
            case .failure(let error):
                print("失敗-請求錯誤-\(error)")
                handler(.failure(error))
            }
        }
    }
    
    static func refreshToken(account: String, token: String, handler: @escaping (Result<String, Error>) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Member/RefreshToken") else { return }
        
        let params = [
            "accountId": account,
            "token": token
        ] as [String: Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response {
            response in
            let statusCode = response.response?.statusCode
            print("refresh:\(statusCode as Any)")
            
            switch response.result {
            case .success(let data):
                if let data = data {
                    let tokon = String(data: data, encoding: .utf8) ?? ""
                    print("更新token:")
                    handler(.success(tokon))
                }
                
            case .failure(let error):
                print("錯誤\(error)")
                handler(.failure(error))
            }
        }
        
    }
    
    
    
    static func postWitness(eventId: String, accountId: String, token: String, isWitness: Int,  handler: @escaping (Bool) -> Void){
        guard let url = URL(string: "https://finaldangermap.appspot.com/api/Instant/IsWitness") else { return }
        //        "eventId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        //          "accountId": "string",
        //          "isWitness": 0
        let params = [
            "eventId": eventId,
            "accountId": accountId,
            "isWitness": isWitness
        ] as [String: Any]
        
        let myHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: myHeaders).response {
            response in
            let statusCode = response.response?.statusCode
            print("postWitness:\(statusCode as Any)")
            
            switch statusCode{
            case 200:
                print("post目擊數量成功")
                handler(true)
            case 401:
                print("Token有錯")
                handler(false)
            case 404:
                print("會員沒有驗證")
                handler(false)
            default:
                print("其他")
                handler(false)
            }
        }
    }
    
}

struct ErrorData: Codable{
    let type: String
    let title: String
    let status: Int
    let traceId: String
    let errors: Errors
    
    struct Errors: Codable {
        let AccountId: [String]
    }
}
