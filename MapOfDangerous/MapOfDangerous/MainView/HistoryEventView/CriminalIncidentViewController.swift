//
//  CriminalIncidentViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/30.
//

import UIKit

class CriminalIncidentViewController: UIViewController {

    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var houseTheft: UILabel!
    @IBOutlet weak var scooterTheft: UILabel!
    @IBOutlet weak var carTheft: UILabel!
    @IBOutlet weak var rob: UILabel!
    @IBOutlet weak var drug: UILabel!
    @IBOutlet weak var snatch: UILabel!
    @IBOutlet weak var rape: UILabel!
    
    var data: CriminalIncidentData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = data{
            setData(district: data.district, snatch: data.snatch, rape: data.rape, rob: data.rob, scooterTheft: data.scooterTheft, carTheft: data.carTheft, drug: data.drug, houseTheft: data.houseTheft)
        }
    }
    
    func setData(district: String, snatch: Int, rape: Int, rob: Int, scooterTheft: Int, carTheft: Int, drug: Int, houseTheft: Int){
        self.districtLabel.text = district
        self.snatch.text = String(snatch)
        self.rape.text = String(rape)
        self.rob.text = String(rob)
        self.carTheft.text = String(carTheft)
        self.scooterTheft.text = String(scooterTheft)
        self.houseTheft.text = String(houseTheft)
        self.drug.text = String(drug)
    }
    

    

}
