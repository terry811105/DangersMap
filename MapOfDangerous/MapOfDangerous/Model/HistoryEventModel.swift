//
//  HistoryEventModel.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/27.
//

import Foundation

class HistoryEventModel{
    
    var allCarAccident: [CarAccidentData] = []
    var allCriminalIncident: CriminalIncidentData?
    
    func getCarAccidentCount()-> Int{
        return allCarAccident.count
    }
    
    func getCriminalIncident()-> CriminalIncidentData?{
        if allCriminalIncident != nil {
            return allCriminalIncident
        } else {
            return nil
        }
    }
    
    func getCarAccidentData(index: Int)-> CarAccidentData?{
        if allCarAccident.indices.contains(index) {
            return allCarAccident[index]
        } else {
            return nil
        }
    }
    
    
    
    func fetchCarAccidentData(latitude: Double, longitude: Double){
        print("來取車禍資料 latitude:\(latitude), longitude:\(longitude)")
        APIManager.getTrafficAccidentData(latitude: latitude, longitude: longitude){
            result in
            switch result{
            case .success(let datas):
                print("")
                self.allCarAccident = datas
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchCarAccidentData"), object: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCriminalIncidentData(latitude: Double, longitude: Double){
        APIManager.getCriminalIncidentData(latitude: latitude, longitude: longitude) { result in
            switch result{
            case .success(let datas):
                print("")
                self.allCriminalIncident = datas
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFetchCriminalIncidentData"), object: nil)
            case .failure(let error):
                print(error)
            }
            
        }
    }
}
