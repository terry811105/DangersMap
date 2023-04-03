//
//  DiscordData.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/17.
//

import Foundation

struct DiscussMessageData: Codable {
//    "accountId": "string",
//        "accountName": "string",
//        "propicLink": "string",
//        "commentTime": "2021-12-30T07:29:16.517Z",
//        "comment": "string"
    
    let accountId: String
    let accountName: String
    let propicLink: String
    let commentTime: String
//    let userPhotoUrl: String?
    let comment: String

}
