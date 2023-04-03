//
//  SelectSkinViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/27.
//

import UIKit

class SelectSkinViewController: UIViewController {

    @IBOutlet var selectSkinButton: [UIButton]!
    @IBOutlet var mapSkinImages: [UIImageView]!
    @IBOutlet var contanViews: [UIView]!
    @IBOutlet weak var normalView: UIView!
    @IBOutlet weak var normalSkin: UIImageView!
    @IBOutlet weak var retroView: UIView!
    @IBOutlet weak var retroSkin: UIImageView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var darkSkin: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in selectSkinButton {
            button.layer.cornerRadius = 15
            button.layer.shadowOpacity = 0.5
        }
        
        for image in mapSkinImages{
            image.layer.cornerRadius = 15
            
        }
        
        for cView in contanViews{
            cView.layer.cornerRadius = 15
            cView.layer.shadowOpacity = 0.5
            
          //  makeShadow(object: cView, offset: .init(width: 1, height: 1))
        }
        
        let tapGetureRecognizerOfNormal = UITapGestureRecognizer(target: self, action: #selector(didTappedNormal(_:)))
        normalView.isUserInteractionEnabled = true
        normalView.addGestureRecognizer(tapGetureRecognizerOfNormal)
        
        let tapGetureRecognizerOfRetro = UITapGestureRecognizer(target: self, action: #selector(didTappedRetro(_:)))
        retroView.isUserInteractionEnabled = true
        retroView.addGestureRecognizer(tapGetureRecognizerOfRetro)
        
        let tapGetureRecognizerOfDark = UITapGestureRecognizer(target: self, action: #selector(didTappedDark(_:)))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(tapGetureRecognizerOfDark)
    }
    
    @objc func didTappedNormal(_ tap: UITapGestureRecognizer){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSelectNormal"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTappedRetro(_ tap: UITapGestureRecognizer){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSelectRetro"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTappedDark(_ tap: UITapGestureRecognizer){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSelectDark"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectCarAccident(_ sender: UIButton) {
        self.dismiss(animated: true){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSelectCarAccidentSkin"), object: nil)
        }
        
    }
    
    
    @IBAction func selectCriminalIncident(_ sender: UIButton) {
        self.dismiss(animated: true){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSelectCriminalIncidentSkin"), object: nil)
        }
    }
    
    func makeShadow(object: UIView, offset: CGSize){
        object.layer.shadowOffset = offset
        object.layer.shadowColor = UIColor.black.cgColor
        object.layer.shadowOpacity = 0.5
        object.layer.shadowRadius = 15
    }
    
}
