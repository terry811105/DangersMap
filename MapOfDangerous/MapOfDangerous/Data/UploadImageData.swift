//
//  UploadImageData.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/23.
//

import Foundation


struct UploadImageResult: Decodable {
    struct Data: Decodable {
        let link: URL
    }
    let data: Data
}
