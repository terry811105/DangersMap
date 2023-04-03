//
//  DangerousDetailData.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/14.
//

import Foundation
import GoogleMaps

struct DangerousDetailData: Codable {
//        "eventId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//        "uploaderAccountId": "string",
//        "uploaderAccountName": "string",
//        "uploaderPropicLink": "string",
//        "type": "string",
//        "title": "string",
//        "description": "string",
//        "longitude": 0,
//        "latitude": 0,
//        "locationDetails": "string",
//        "uploadTime": "2022-01-04T08:41:14.309Z",
//        "shotLink": "string",
//        "totalWitness": 0,
//        "totalNotWitness": 0,
//        "isWitness": 0
    let eventId: String
    let uploaderAccountId: String
    let uploaderAccountName: String
    let uploaderPropicLink: String
    let type: String
    let title: String
    let longitude: Double
    let latitude: Double
    let description: String
    let uploadTime: String
    let shotLink: String?
    let locationDetails: String?
    let totalWitness: Int
    let totalNotWitness: Int
    let isWitness: Int

}

