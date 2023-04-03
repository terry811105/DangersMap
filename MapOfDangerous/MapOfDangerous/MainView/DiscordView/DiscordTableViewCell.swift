//
//  DiscordTableViewCell.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/17.
//

import UIKit
import SDWebImage


class DiscordTableViewCell: UITableViewCell {

    @IBOutlet weak var outsideView: UIView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var uploadTime: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    
    static let reuseIdentifier = "DiscordTableViewCell"
    
    func setData(name: String, time: String, message: String, userPhotoUrl: String ){
        userName.text = name
        uploadTime.text = time
        describeLabel.text = message
        
        let imageUrl = URL(string: userPhotoUrl)
        userPhoto.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "person.fill"))
        
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = 17
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
