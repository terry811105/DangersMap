//
//  DangerousModel.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/14.
//

import Foundation

class DangerousModel {
    
    
    var allDangerousData: [String: DangerousDetailData] = [:]
    var allDiscussData: [String: [DiscussMessageData]] = [:]
    
    func fetchDangerData(){
        APIManager.getDangerousData { result in
            switch result {
            case .success(let datas):
                print("取得api成功")
                //    self.allDangerousData = datas
                for data in datas{
                    self.allDangerousData[data.eventId] = data
                    //                    let newMessageArray: [DiscussMessageData] = []
                    //                    self.allDiscussData.append(newMessageArray)
                }
                //         print(datas)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchDangerData"), object: nil)
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func fetchRangeDataByMeters(meters: Int, latitude: Double, longitude: Double){
        APIManager.getRangeDangerDataByMeters(meters: meters, latitude: latitude, longitude: longitude){ datas in
            var rangeDangerousData: [String: DangerousDetailData] = [:]
            if datas.count > 0 {
                for data in datas{
                    rangeDangerousData[data.eventId] = data
                }
            }
            self.allDangerousData = rangeDangerousData
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchDangerData"), object: nil)
        }
    }
    
    func fetchRangeDangerData(accountId: String, latitude: Double, longitude: Double){
        APIManager.getRangeDangerDataWithId(accountId: accountId, latitude: latitude, longitude: longitude) {
            result in
            switch result {
            case .success(let datas):
                print("有登入的人取得範圍api成功")
                
                var rangeDangerousData: [String: DangerousDetailData] = [:]
                if datas.count > 0 {
                    for data in datas{
                        rangeDangerousData[data.eventId] = data
                    }
                }
                
                self.allDangerousData = rangeDangerousData
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchDangerData"), object: nil)

            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func fetchRangeDangerData(latitude: Double, longitude: Double){
        APIManager.getRangeDangerData(latitude: latitude, longitude: longitude) {
            result in
            switch result {
            case .success(let datas):
                print("取得範圍api成功")
                var rangeDangerousData: [String: DangerousDetailData] = [:]
                if datas.count > 0 {
                    for data in datas{
                        rangeDangerousData[data.eventId] = data
                    }
                }
                self.allDangerousData = rangeDangerousData
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchDangerData"), object: nil)
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func fetchDiscussionData(eventID: String){
        APIManager.getDiscussionData(eventID: eventID) { result in
            switch result {
            case .success(let discussions):
                print("取得留言資訊成功")
                //     print(discussions)
                self.allDiscussData[eventID] = discussions
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchDiscussionData"), object: nil)
            case .failure(let error):
                print(error)
                
            }
            
        }
    }
    
    //    func addNewData(newData: DangerousDetailData){
    //        self.allDangerousData.append(newData)
    //        let newMessageArray: [DiscussMessageData] = []
    //        self.allDiscussData.append(newMessageArray)
    //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didAddData"), object: nil)
    //    }
    
    //    func addMessage(newMessage: DiscussMessageData, index: Int){
    //
    //        self.allDiscussData[index].append(newMessage)
    //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didAddMessage"), object: nil)
    //    }
    
    func getDataCount() -> Int {
        return allDangerousData.count
    }
    
    func getDiscussCount(eventId: String) -> Int {
        if let count = allDiscussData[eventId]?.count {
            return count
        } else {
            return 0
        }
        
    }
    
    func getData(eventID: String) -> DangerousDetailData? {
        if allDangerousData[eventID] != nil {
            return allDangerousData[eventID]
        } else {
            print("沒有東西")
            return nil
        }
    }
    
    func getMessage(eventID: String, index: Int) -> DiscussMessageData? {
        //
        print("取留言資料...")
        if let discussions = allDiscussData[eventID] {
            //      print(discussions)
            return discussions[index]
            
        }else {
            print("eventID找不到東西")
            return nil
        }
        
    }
    
    
    
}
