//
//  HistoryEventViewController.swift
//  MapOfDangerous
//
//  Created by 張文煥 on 2021/12/27.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

class HistoryEventViewController: UIViewController {
    
    enum eventType{
        case carAccident
        case criminalIncident
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var noDataLabel: UILabel!
    var myLocationMgr: CLLocationManager!
    
    var clusterManager: GMUClusterManager!
    
    let model = HistoryEventModel()
    
    var eventType: eventType?
    @IBOutlet weak var informationView: UIView!
    
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var houseTheft: UILabel!
    @IBOutlet weak var scooterTheft: UILabel!
    @IBOutlet weak var carTheft: UILabel!
    @IBOutlet weak var rob: UILabel!
    @IBOutlet weak var drug: UILabel!
    @IBOutlet weak var snatch: UILabel!
    @IBOutlet weak var rape: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        informationView.layer.cornerRadius = 10
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
        
        
        // 生成 Cluster Manager
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
        self.clusterManager.setDelegate(self, mapDelegate: self)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didFetchCarAccidentData"), object: nil, queue: nil)  {
            noti in
            self.setEventMarker()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didFetchCriminalIncidentData"), object: nil, queue: nil)  {
            noti in
       //     let sb = UIStoryboard(name: "HistoryEventViewController", bundle: nil)
         //   if let vc = sb.instantiateViewController(withIdentifier: "CriminalIncidentViewController") as? CriminalIncidentViewController {
            
                guard let data = self.model.getCriminalIncident() else {
                    
                    self.noDataLabel.isHidden = false
                    self.informationView.isHidden = false
                    return }
                print(data)
     //           vc.data = data
            self.setData(district: data.district, snatch: data.snatch, rape: data.rape, rob: data.rob, scooterTheft: data.scooterTheft, carTheft: data.carTheft, drug: data.drug, houseTheft: data.houseTheft)
//                let sheetVC = vc.sheetPresentationController!
//                sheetVC.detents = [.medium()]
//                sheetVC.prefersGrabberVisible = true
//                self.present(vc, animated: true, completion: nil)
         //   }
            self.informationView.isHidden = false
        }
        
        
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
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
    
    func setEventMarker(){
        
        clusterManager.clearItems()
        let count = self.model.getCarAccidentCount()
//        let markerList = model.allCarAccident
//        self.initMapViewMarker(markerList)
        print("有\(count)筆車禍")
        if count != 0 {
            for i in 0...count-1 {
                let marker = GMSMarker()
                guard let data = self.model.getCarAccidentData(index: i) else { return }
                
                marker.title = "死亡人數：\(data.death)"
                marker.snippet = "受傷人數：\(data.injury)"
                marker.position = .init(latitude: data.latitude, longitude: data.longitude)
                clusterManager.add(marker)
              //  marker.map = self.mapView
            }
        }
    }
    
    /// 初始化地圖上的 Cluster Item
    /// - Parameter markerDataFromServerDataList: _
    private func initMapViewMarker(_ markerDataFromServerDataList: [CarAccidentData]) {
        markerDataFromServerDataList
            .map{ MyMaker(markerData: $0) }
            .forEach {
                let item = ClusterItem(markerData: $0.markerData)
                self.clusterManager.add(item)
            }
        
        self.clusterManager.cluster()
    }
    
    
    
}

extension HistoryEventViewController: GMUClusterRendererDelegate{
    /// 回傳一標記，此 delegate 可用來控制標記的生命週期。例如:設定標記的座標、圖片等等
    /// - Parameter renderer: _
    /// - Parameter object: _
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        switch object {
        case let clusterItem as ClusterItem:
            return MyMaker(markerData: clusterItem.markerData)
        default:
            return nil
        }
    }
}

extension HistoryEventViewController: GMUClusterManagerDelegate{
    // 點擊叢集所會觸發的事件
    /// - Parameter clusterManager: _
    /// - Parameter cluster: _
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        print("didTap cluster")
        return false
    }
    
    /// 點擊叢集項目所會觸發的事件
    /// - Parameter clusterManager: _
    /// - Parameter clusterItem: _
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        print("didTap clusterItem")
        return false
    }
}

extension HistoryEventViewController: GMSMapViewDelegate, CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 18)
//            if self.eventType == .carAccident{
//                model.fetchCarAccidentData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            } else if self.eventType == .criminalIncident {
//                print("選擇犯罪事件")
//                model.fetchCriminalIncidentData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            }
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
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Tapped at coordinate: " + String(coordinate.latitude) + " "
              + String(coordinate.longitude))
        if self.eventType == .carAccident{
            print("選擇車禍資訊")
            model.fetchCarAccidentData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        } else if self.eventType == .criminalIncident {
            print("選擇犯罪事件")
            model.fetchCriminalIncidentData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        
    }
    
    // 2 did Loong Press Map
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            print("gesture:\(gesture)")
            print("有手勢在動")
            
        }
        
        if self.eventType == .criminalIncident {
            self.informationView.isHidden = true
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("動畫結束")
        if self.eventType == .carAccident{
            model.fetchCarAccidentData(latitude: position.target.latitude, longitude: position.target.longitude)
        } else if self.eventType == .criminalIncident {
            print("選擇犯罪事件")
            model.fetchCriminalIncidentData(latitude: position.target.latitude, longitude: position.target.longitude)
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {

        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        
        return false
    }
}

class MyMaker: GMSMarker {
    let markerData: CarAccidentData // Raw data from server
    
    init(markerData: CarAccidentData) {
        self.markerData = markerData
        super.init()
        self.position = .init(latitude: markerData.latitude, longitude: markerData.longitude)
    }
}

class ClusterItem: NSObject, GMUClusterItem {
    let markerData: CarAccidentData // Raw data from server
    let position: CLLocationCoordinate2D
    
    init(markerData: CarAccidentData) {
        self.markerData = markerData
        self.position = .init(latitude: markerData.latitude, longitude: markerData.longitude)
    }
}
