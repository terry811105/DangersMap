//
//  ViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/13.
//

import UIKit
import GoogleMaps
import MarqueeLabel
import SwiftKeychainWrapper
import WebKit
import SafariServices

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var noDataNoteView: UIView!
    @IBOutlet weak var societySafe: UIButton!
    @IBOutlet weak var changeSkinButtonContantView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var tagButtons: [UIButton]!
    @IBOutlet weak var changeSkinButton: UIButton!
    @IBOutlet weak var marqueeLabel: MarqueeLabel!
    
    var myLocationMgr: CLLocationManager!
    
    var lat = Double()
    var lon = Double()
    
    var isFirstTimeIn: Bool = true
    
    var tags: [Bool] = []
    
    var isTag1Press: Bool = false
    var isTag2Press: Bool = false
    var isTag3Press: Bool = false
    var isTag4Press: Bool = false
    var isTag5Press: Bool = false
    
    let model = DangerousModel()
    
    var currentMapMarket: GMSMarker?
    
    @IBOutlet weak var addMarkButton: UIButton!
    @IBOutlet weak var runTextView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = KeychainWrapper.standard.string(forKey: "token"), let accountId = KeychainWrapper.standard.string(forKey: "accountId"){
            APIManager.refreshToken(account: accountId, token: token) {
                re in
                switch re{
                case .success(let token):
                    if KeychainWrapper.standard.removeObject(forKey: "token"){
                        print("一登入就刪掉舊token")
                        if KeychainWrapper.standard.set(token, forKey: "token"){
                            print("一登入重新refresh token")
                            
                        }
                    }
                case .failure(_):
                    print("refresh失敗gg")
                }
            }
        }
        
        APIManager.getNewsTicker{ re in
            switch re{
            case .success(let datas):
                for i in 0...datas.count-1{
                    self.marqueeLabel.text?.append(" 🔔\(datas[i].title)    ")
                }
                self.marqueeLabel.text?.append("             ")
            case .failure(_):
                print("")
            }
        }
        
        marqueeLabel.type = .left
        marqueeLabel.type = .continuous
        marqueeLabel.speed = .rate(55)
        marqueeLabel.fadeLength = 10
        marqueeLabel.trailingBuffer = 30
        marqueeLabel.animateForController(Notification.init(name: Notification.Name("didEndAnimation"), object: nil, userInfo: nil))
        
        changeSkinButton.layer.cornerRadius = 17.5
        changeSkinButtonContantView.layer.cornerRadius = 17.5
        changeSkinButtonContantView.layer.shadowOpacity = 0.5
        
  //      makeShadow(object: changeSkinButton, offset: CGSize.init(width: 5, height: 5))
        
        for button in tagButtons {
            
            button.layer.cornerRadius = 10
            button.layer.shadowOpacity = 0.5
       //     makeShadow(object: button, offset: CGSize.init(width: 5, height: 5)) // didn't work
        }
        
        //      runTextLabel.mask = maskView
        
        addMarkButton.layer.cornerRadius = 25
        
        mapView.delegate = self
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        mapView.mapType = .normal
        
        myLocationMgr = CLLocationManager()
        myLocationMgr.delegate = self
        myLocationMgr.requestWhenInUseAuthorization() // request user authorize
        myLocationMgr.distanceFilter = kCLLocationAccuracyNearestTenMeters // update data after move ten meters
        myLocationMgr.desiredAccuracy = kCLLocationAccuracyBest
        
        let tapGetureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didLabelTapped(_:)))
        marqueeLabel.isUserInteractionEnabled = true
        marqueeLabel.addGestureRecognizer(tapGetureRecognizer)
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didSelectNormal"), object: nil, queue: nil)  {
            noti in
            self.mapView.mapStyle = nil
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didSelectRetro"), object: nil, queue: nil)  {
            noti in
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                    self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didSelectDark"), object: nil, queue: nil)  {
            noti in
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "styleDark", withExtension: "json") {
                    self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didPostData"), object: nil, queue: nil)  {
            noti in
            guard let latitude = self.myLocationMgr.location?.coordinate.latitude else { return }
            guard let longitude = self.myLocationMgr.location?.coordinate.longitude else { return }
            self.model.fetchRangeDangerData(latitude: latitude, longitude: longitude)
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didFetchDangerData"), object: nil, queue: nil)  {
            noti in
//            if self.isFirstTimeIn {
//                print("First Time Use")
//                self.setMarkerAtFirst()
//
//            }
            if self.isAnyTagSelected(){
                self.resetMarker()
            }else {
                self.setMarkerAtFirst()
            }
            
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didSelectCarAccidentSkin"), object: nil, queue: nil)  {
            noti in
            let storyboard = UIStoryboard(name: "HistoryEventViewController", bundle: .main)
            if let historyVC = storyboard.instantiateViewController(withIdentifier: "HistoryEventViewController") as? HistoryEventViewController{
                historyVC.eventType = .carAccident
                self.navigationController?.pushViewController(historyVC, animated: true)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didSelectCriminalIncidentSkin"), object: nil, queue: nil)  {
            noti in
            let storyboard = UIStoryboard(name: "HistoryEventViewController", bundle: .main)
            if let historyVC = storyboard.instantiateViewController(withIdentifier: "HistoryEventViewController") as? HistoryEventViewController{
                historyVC.eventType = .criminalIncident
                self.navigationController?.pushViewController(historyVC, animated: true)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //   model.fetchDangerData()
//        guard let latitude = self.myLocationMgr.location?.coordinate.latitude else { return }
//        guard let longitude = self.myLocationMgr.location?.coordinate.longitude else { return }
//        self.model.fetchRangeDangerData(latitude: latitude, longitude: longitude)
        
        MarqueeLabel.controllerViewWillAppear(self)
        
    }
    
    func getMapMeters(magicNumber: Float) -> Int{
        if magicNumber == 21{
            print("倍率=21")
            return 100
        } else if magicNumber < 21 && magicNumber >= 19 {
            print("倍率=19~21")
            return 500
        } else if magicNumber < 19 && magicNumber >= 17 {
            print("倍率=17~19")
            return 1500
        } else if magicNumber < 17 && magicNumber >= 15 {
            print("倍率=15~17")
            return 10000
        } else {
            print("倍率<15")
            return 100000
        }
    }
    
    func checkValidation() -> Bool{
        var isValidation = false
        let group = DispatchGroup()
        DispatchQueue.global().async {
            if let accountId = KeychainWrapper.standard.string(forKey: "accountId"), let token = KeychainWrapper.standard.string(forKey: "token"){
                group.enter()
                APIManager.getMemberInfo(accountId: accountId, token: token) { result in
                    switch result{
                    case .success(let memberData):
                        print("會員資料成功")
                        if memberData.validation{
                            print("有驗證")
                            isValidation =  true
                            group.leave()
                        } else {
                            print("沒驗證")
                            isValidation = false
                            group.leave()
                        }
                    case .failure(_):
                        print("")
                        isValidation = false
                        group.leave()
                    }
                }
            } else {
                isValidation = false
            }
        }
        
        
        print("return -> \(isValidation)")
        return isValidation
    }
    
    func isAnyTagSelected()-> Bool{
        let tagList = [isTag1Press, isTag2Press, isTag3Press, isTag4Press, isTag5Press]
        for tag in tagList where tag == true {
            return true
        }
        return false
    }
    
    func setMarkerAtFirst(){
        noDataNoteView.isHidden = true
        print("先清地圖，setMarkerAtFirst()")
        mapView.clear()
        let count = self.model.getDataCount()
        
        if count != 0 {
            for item in model.allDangerousData {
                let marker = GMSMarker()
                guard let data = self.model.getData(eventID: item.key) else { return }
                marker.position = .init(latitude: data.latitude, longitude: data.longitude)
                switch data.type{
                case "公共危險":
                    let icon = UIImage(named: "knife")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
                    //    marker.icon = UIImage(systemName: "burst.fill")
                case "道路安全":
                    let icon = UIImage(named: "cone_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
                    
                    //     marker.icon = UIImage(systemName: "car")
                case "社會安全":
                    let icon = UIImage(named: "team_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
                case "環境事件":
                    let icon = UIImage(named: "planet-earth_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
                case "生物防治":
                    let icon = UIImage(named: "footprint_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
                default:
                    marker.icon = UIImage(systemName: "tag.fill")
                }
                marker.title = data.eventId
                
                marker.map = self.mapView
            }
        } else {
            noDataNoteView.isHidden = false
        }
    }
    
    func resetMarker(){
        print("先清地圖，resetMarker()")
        noDataNoteView.isHidden = true
        mapView.clear()
        
        let count = self.model.getDataCount()
        
        print("現在要來reset地圖，有幾個資料：\(count)")
        if count != 0 {
            for item in model.allDangerousData {
                let marker = GMSMarker()
                guard let data = self.model.getData(eventID: item.key) else { return }
                marker.position = .init(latitude: data.latitude, longitude: data.longitude)
          //      print("現在這個資料的種類是：\(data.type)")
                switch data.type{
                case "公共危險":
                    let icon = UIImage(named: "knife")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
             //       print("公共危險有被按下嗎？\(isTag1Press)")
                    if isTag1Press {
                        marker.title = data.eventId
               //         print("顯示公共危險")
                        marker.map = self.mapView
                    }
                case "社會安全":
                    let icon = UIImage(named: "team_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
              //      print("社會安全有被按下嗎？\(isTag2Press)")
                    if isTag2Press {
                        marker.title = data.eventId
               //         print("顯示社會安全")
                        marker.map = self.mapView
                    }
                case "道路安全":
                    let icon = UIImage(named: "cone_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
              //      print("道路安全有被按下嗎？\(isTag3Press)")
                    if isTag3Press {
                        marker.title = data.eventId
               //         print("顯示道路安全")
                        marker.map = self.mapView
                    }
                case "環境事件":
                    let icon = UIImage(named: "planet-earth_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
             //       print("環境事件有被按下嗎？\(isTag4Press)")
                    if isTag4Press {
                        marker.title = data.eventId
             //           print("顯示環境事件")//
                        marker.map = self.mapView
                    }
                case "生物防治":
                    let icon = UIImage(named: "footprint_0")
                    let markerView = UIImageView(image: icon)
                    marker.iconView = markerView
             //       print("生物防治有被按下嗎？\(isTag5Press)")
                    if isTag5Press {
                        marker.title = data.eventId
             //           print("顯示生物防治")
                        marker.map = self.mapView
                    }
                    
                default:
                    marker.icon = UIImage(systemName: "tag.fill")
                }
                
            }
        } else {
            noDataNoteView.isHidden = false
        }
    }
    
    @IBAction func clickChangeSkin(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "SelectSkinViewController") as? SelectSkinViewController {
            
            let sheetVC = vc.sheetPresentationController!
            sheetVC.detents = [.medium(), .large()]
            sheetVC.prefersGrabberVisible = true
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickTag1(_ sender: UIButton) {
        isTag1Press = !isTag1Press
        
        if isTag1Press {
            print("公共危險按下")
            
            sender.backgroundColor = UIColor(named: "pressYellow")
            
        } else {
            print("公共危險再次按下")
            sender.backgroundColor = .white
        }
        mapView.clear()
        if isAnyTagSelected(){
            resetMarker()
        }else {
            setMarkerAtFirst()
        }
        
    }
    
    @IBAction func clickTag2(_ sender: UIButton) {
        isTag2Press = !isTag2Press
        if isTag2Press {
            print("社會安全按下")
            sender.backgroundColor = UIColor(named: "pressYellow")
            
        } else {
            sender.backgroundColor = .white
        }
        mapView.clear()
        if isAnyTagSelected(){
            resetMarker()
        }else {
            setMarkerAtFirst()
        }
    }
    
    @IBAction func clickTag3_car(_ sender: UIButton) {
        isTag3Press = !isTag3Press
        if isTag3Press {
            print("道路安全按下")
            sender.backgroundColor = UIColor(named: "pressYellow")
        } else {
            sender.backgroundColor = .white
        }
        mapView.clear()
        if isAnyTagSelected(){
            resetMarker()
        }else {
            setMarkerAtFirst()
        }
    }
    
    @IBAction func clickTag4(_ sender: UIButton) {
        isTag4Press = !isTag4Press
        if isTag4Press {
            print("環境事件按下")
            sender.backgroundColor = UIColor(named: "pressYellow")
        } else {
            sender.backgroundColor = .white
        }
        mapView.clear()
        if isAnyTagSelected(){
            resetMarker()
        }else {
            setMarkerAtFirst()
        }
    }
    
    @IBAction func clickTag5_animal(_ sender: UIButton) {
        isTag5Press = !isTag5Press
        if isTag5Press {
            print("生物防治按下")
            sender.backgroundColor = UIColor(named: "pressYellow")
        } else {
            sender.backgroundColor = .white
        }
        mapView.clear()
        if isAnyTagSelected(){
            resetMarker()
        }else {
            setMarkerAtFirst()
        }
    }
    
    @IBAction func clickAddMarkButton(_ sender: Any) {

        guard let latitude = self.myLocationMgr.location?.coordinate.latitude else { return }
        guard let longitude = self.myLocationMgr.location?.coordinate.longitude else { return }
        print(mapView.camera.zoom)
        
        print("latitude:\(latitude),longitude:\(longitude)")
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //    let currentLocation: CLLocation = locations[0] as CLLocation
        if let location = locations.first {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 18)
            print("變動位置")
            if let accountId = KeychainWrapper.standard.string(forKey: "accountId"){
                model.fetchRangeDangerData(accountId: accountId, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            } else {
                model.fetchRangeDangerData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
            
            myLocationMgr.stopUpdatingLocation()
        }
        
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            myLocationMgr.startUpdatingLocation() // Start location
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        case .denied:
            let alertController = UIAlertController(title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func makeShadow(object: UIView, offset: CGSize){
        object.layer.shadowOffset = offset
        object.layer.shadowColor = UIColor.black.cgColor
        object.layer.shadowOpacity = 0.5
        object.layer.shadowRadius = 10
    }
    
    @objc func didLabelTapped(_ tap: UITapGestureRecognizer){
        guard let url = URL(string: "https://www.tfdp.com.tw/cht/index.php") else {
            return
        }
        let safariVC = SFSafariViewController.init(url: url)
        present(safariVC, animated: true)
    }
    
}

extension ViewController: GMSMapViewDelegate{
    
    
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            print("gesture:\(gesture)")
            print("有手勢在動")
        }
        self.isFirstTimeIn = false
       
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("動畫結束")
        print("camera zoom: \(mapView.camera.zoom)")
        print("CameraPosition -> latitude:\(position.target.latitude), longitude: \(position.target.longitude)")
        if let accountId = KeychainWrapper.standard.string(forKey: "accountId"){
            model.fetchRangeDangerData(accountId: accountId, latitude: position.target.latitude, longitude: position.target.longitude)
        } else {
//            model.fetchRangeDangerData(latitude: position.target.latitude, longitude: position.target.longitude)
            model.fetchRangeDataByMeters(meters: getMapMeters(magicNumber: mapView.camera.zoom), latitude: position.target.latitude, longitude: position.target.longitude)
        }
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Tapped at coordinate: " + String(coordinate.latitude) + " "
              + String(coordinate.longitude))
//        model.fetchRangeDangerData(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        if checkValidation(){
        
            currentMapMarket?.map = nil
            
            lat = coordinate.latitude
            lon = coordinate.longitude
            currentMapMarket = GMSMarker(position: coordinate)
            currentMapMarket?.position = coordinate
            currentMapMarket?.isDraggable = true
            currentMapMarket?.map = self.mapView

            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "InputDetailInfoViewController") as? InputDetailInfoViewController {
                vc.dataLocation = coordinate
                vc.model = self.model
                let sheetVC = vc.sheetPresentationController!
                sheetVC.detents = [.medium(), .large()]
                sheetVC.prefersGrabberVisible = true
                present(vc, animated: true, completion: nil)
            }
        // }
        
    }
    
    // 2 did Loong Press Map
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("Tapped at coordinate: " + String(coordinate.latitude) + " "
              + String(coordinate.longitude))
        currentMapMarket?.map = nil
        
        lat = coordinate.latitude
        lon = coordinate.longitude
        currentMapMarket = GMSMarker(position: coordinate)
        currentMapMarket?.position = coordinate
        currentMapMarket?.isDraggable = true
        currentMapMarket?.map = self.mapView

        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "InputDetailInfoViewController") as? InputDetailInfoViewController {
            vc.dataLocation = coordinate
            vc.model = self.model
            let sheetVC = vc.sheetPresentationController!
            sheetVC.detents = [.medium(), .large()]
            sheetVC.prefersGrabberVisible = true
            present(vc, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if marker.title != nil {
            if let vc = sb.instantiateViewController(withIdentifier: "DiscussViewController") as? DiscussViewController {
                guard let title = marker.title else {
                    print("沒有標題")
                    return false }
                print("大頭針的標題：\(title)")
                
                //     print(index)
                vc.data = model.getData(eventID: title)
                vc.eventID = title
                //      vc.index = index
                vc.model = self.model
                //     vc.dataTitle = marker.title
                let sheetVC = vc.sheetPresentationController!
                sheetVC.detents = [.medium() ,.large()]
                sheetVC.prefersGrabberVisible = true
                present(vc, animated: true, completion: nil)
            }
        } else {
            if let vc = sb.instantiateViewController(withIdentifier: "InputDetailInfoViewController") as? InputDetailInfoViewController {
                vc.dataLocation = marker.position
                vc.model = self.model
                let sheetVC = vc.sheetPresentationController!
                sheetVC.detents = [.medium(), .large()]
                sheetVC.prefersGrabberVisible = true
                present(vc, animated: true, completion: nil)
            }
        }
        
        //    print(marker.title as Any)
        return true
    }
}

