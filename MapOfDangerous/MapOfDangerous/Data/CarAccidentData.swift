//
//  CarAccidentData.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/27.
//

import Foundation

struct CarAccidentData: Codable{
//    "accidentId": 0,
//        "time": "2021-12-27T13:29:56.139Z",
//        "death": 0,
//        "injury": 0,
//        "longitude": 0,
//        "latitude": 0
    let accidentId: Int
    let time: String
    let death: Int
    let injury: Int
    let longitude: Double
    let latitude: Double
    
}
