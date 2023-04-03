//
//  CriminalIncidentData.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/30.
//

import Foundation

struct CriminalIncidentData: Codable{
//    "district": "string",
//      "snatch": 0,
//      "rape": 0,
//      "rob": 0,
//      "carTheft": 0,
//      "scooterTheft": 0,
//      "drug": 0,
//      "houseTheft": 0
    // 區域
    let district: String
    // 搶奪
    let snatch: Int
    // 強制性交
    let rape: Int
    // 強盜
    let rob: Int
    // 汽車竊盜
    let carTheft: Int
    // 機車竊盜
    let scooterTheft: Int
    // 毒品
    let drug: Int
    // 住宅竊盜
    let houseTheft: Int
    
}
