//
//  ViewController.swift
//  iBike
//
//  Created by 翟靖庭 on 14/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let transition = SlideInTransition()
    var topView: UIView?
    
    var tappedMarker: GMSMarker?
    var infoWindowView : InfoWindowView?
    
    private let locationManager = CLLocationManager()
    //    var currentLocation : CLLocation!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var nearbyButton: UIButton!
    @IBOutlet weak var nearbyView: UIView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var nearbyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 24.164005, longitude: 120.637622, zoom: 14.0)
        mapView.camera = camera
        jsonMap()
        
        searchView.layer.borderColor = UIColor.lightGray.cgColor
        searchView.layer.borderWidth = 1
        
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        
        mapView.delegate = self
        nearbyTableView.dataSource = self
        nearbyTableView.delegate = self
        locationSearchBar.delegate = self
        locationSearchBar.showsCancelButton = true
        
        let backButton = locationSearchBar.value(forKey: "cancelButton") as! UIButton
        backButton.setTitle("返回", for: .normal)
        
        let currentLocationLat = locationManager.location!.coordinate.latitude
        let currentLocationLong = locationManager.location!.coordinate.longitude
        print(currentLocationLat)
        print(currentLocationLong)
        
        //                self.tappedMarker = GMSMarker()
        //                self.infoWindowView = InfoWindowView().loadView()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
    }
    
    var stations = [ALLiBike]()
    var nearbyStationsArray : [ALLiBike] = []
    var allStationsArray : [ALLiBike] = []
    var searchResults : [ALLiBike] = []
    
    func jsonMap() {
        
        guard let mapUrl = URL(string: "http://e-traffic.taichung.gov.tw/DataAPI/api/YoubikeAllAPI") else { return }
        
        /*上傳下載資料*/
        URLSession.shared.dataTask(with: mapUrl) { (data, response, error) in
            
            if error == nil {
                do {
                    self.stations = try JSONDecoder().decode([ALLiBike].self, from: data!)
                    print(self.stations.count)
                    
                    /*讓更新的Code在Main Thread下執行*/
                    DispatchQueue.main.async {
                        
                        
                        for state in self.stations {
                            
                            let allStations = ALLiBike.init(X: Double(state.X!), Y: Double(state.Y!), Position: String(state.Position!), CAddress: String(state.CAddress!), AvailableCNT: state.AvailableCNT!, EmpCNT: state.EmpCNT!, UpdateTime: String(state.UpdateTime!))
                            
                            self.allStationsArray.append(allStations)
                            
                            /*經緯度型別是Double*/
                            let long = Double(state.X!)
                            let lat = Double(state.Y!)
                            
                            let state_marker = GMSMarker()
                            let GMSlonglat = state_marker
                            print(GMSlonglat)
                            
                            state_marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            state_marker.title = "\(state.Position!)"
                            let GMSCname = state_marker.title
                            print(GMSCname!)
                            state_marker.snippet = "\(state.CAddress!)\n可借車位：\(state.AvailableCNT!), 可停空位：\(state.EmpCNT!)\nUpdate Time：\(state.UpdateTime!)"
                            state_marker.icon = UIImage(named: "iBikeMarker")
                            
                            /*無車可借 & 車位滿載*/
                            if state.AvailableCNT! == 0 {
                                state_marker.icon = UIImage(named: "noiBike")
                            }
                            if state.EmpCNT == 0 {
                                state_marker.icon = UIImage(named: "noParkingSpace")
                            }
                            
                            state_marker.map = self.mapView
                            
                        }
                        
                    }
                    
                } catch let jsonError{
                    print("Error: \(jsonError)")
                }
            }
        }.resume()
        
    }
    
    enum tableViewMode : Int {
        case showAllStation
        case showNearbyStation
        case showSearchResult
        
    }
    
    var mode : tableViewMode = .showAllStation
    
    @IBAction func didTapNearbyButton(_ sender: Any) {
        
        if (nearbyView.isHidden == true) {
            mode = .showNearbyStation
            nearbyTableView.reloadData()
            nearbyView.isHidden = false
            
        }
            
        else {
            nearbyView.isHidden = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch mode {
            
        case .showAllStation:
            return stations.count
            
        case .showNearbyStation:
            return nearbyStationsArray.count
            
        case .showSearchResult:
            return searchResults.count
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyStationCell") as? NearbyTableViewCell {
            var data: ALLiBike?
            
            switch mode {
                
            case .showAllStation:
                data = stations[indexPath.row]
                
            case .showNearbyStation:
                data = nearbyStationsArray[indexPath.row]

            case .showSearchResult:
                
                data = searchResults[indexPath.row]
                
            }
            
            cell.stationNameButton.contentHorizontalAlignment = .leading
            cell.stationNameButton.setTitle(data?.Position!, for: .normal)
            cell.iBikeImageView.image = UIImage(named: "bicycleMark")
            cell.iBikeLabel.text = String((data?.AvailableCNT!)!)
            cell.parkingImageView.image = UIImage(named: "parkingMark")
            cell.parkingLabel.text = String((data?.EmpCNT!)!)
            cell.addressLabel.text = String((data?.CAddress!)!)
            
            
            return cell
            
        }
        return UITableViewCell()
    }
    

    var selectedMarker = GMSMarker()
    @IBAction func didTapStationName(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal)
        print(buttonTitle!)
        
        for item in self.stations {
            if  buttonTitle == item.Position! {
                
                selectedMarker.position = CLLocationCoordinate2D(latitude: Double(item.Y!), longitude: Double(item.X!))
                selectedMarker.map = mapView
                mapView.animate(toLocation: selectedMarker.position)
                
                let currentLocationLat = locationManager.location!.coordinate.latitude
                let currentLocationLong = locationManager.location!.coordinate.longitude
                let destinationLat = Double(item.Y!)
                let destinationLong = Double(item.X!)
                
                let origin = "\(currentLocationLat),\(currentLocationLong)"
                let destination = "\(destinationLat),\(destinationLong)"
                
                let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyAmkTSjQIXl9HaUUKtKNLLdnhL27jTdVAA"
                
                AF.request(url).responseJSON { (reseponse) in
                    guard let data = reseponse.data else {
                        return
                    }
                    
                    do {
                        let jsonData = try JSON(data: data)
                        let routes = jsonData["routes"].arrayValue
                        
                        for route in routes {
                            let overview_polyline = route["overview_polyline"].dictionary
                            let points = overview_polyline?["points"]?.string
                            let path = GMSPath.init(fromEncodedPath: points ?? "")
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeColor = .systemBlue
                            polyline.strokeWidth = 5
                            polyline.map = self.mapView
                            
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
                
                nearbyView.isHidden = true
            }
            
        }
        
        
        selectedMarker.zIndex = 1
        selectedMarker.icon = UIImage(named: "showiBikeMarker")
    }
    
    @IBAction func didTapMenu(_ sender: UIButton) {
        guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.tapMenuType = {
            MenuType in
            self.transitionToNewContent(MenuType)
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }
    
    func transitionToNewContent(_ menuType: MenuType) {
        self.title = title
        
        topView?.removeFromSuperview()
        switch menuType {
        case .官方網站:
            let view = UIView()
            view.backgroundColor = .white
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        case .服務中心:
            let view = UIView()
            view.backgroundColor = .white
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        case .車友集結:
            let view = UIView()
            view.backgroundColor = .white
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
            
        default:
            break
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}


/*動畫控制器，繼承至NSObject*/
class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    /*我們是否正在Menu頁面*/
    var isPresenting = false
    
    let dimmingView = UIView()
    
    /*轉場動畫時間*/
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    /*具體轉場動畫*/
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
            else {
                return
        }
        
        /*視圖大小控制*/
        let containerView = transitionContext.containerView
        let finalWidth = toViewController.view.bounds.width * 0.8
        let finalHeight = toViewController.view.bounds.height
        
        /*從Ｍenu到Ｍenu內部選項*/
        if isPresenting {
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.0
            containerView.addSubview(dimmingView)
            dimmingView.frame = containerView.bounds
            
            containerView.addSubview(toViewController.view)
            
            toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: finalHeight)
        }
        
        /*跳出Ｍenu的動畫*/
        let transform = {
            self.dimmingView.alpha = 0.5
            toViewController.view.transform = CGAffineTransform(translationX: finalWidth, y: 0)
        }
        
        /*離開Ｍenu的動畫*/
        let identity = {
            self.dimmingView.alpha = 0.0
            fromViewController.view.transform = .identity
        }
        /*過渡動畫的持續時間 以及 是否取消轉換*/
        let duration = transitionDuration(using: transitionContext)
        let isCancelled = transitionContext.transitionWasCancelled
        
        /*True跳出Ｍenu，False離開Menu*/
        UIView.animate(withDuration: duration, animations: {self.isPresenting ? transform() : identity()})
            /*通知系統轉場結束*/
        { (_) in
            transitionContext.completeTransition(!isCancelled)
        }
    }
    
    
}

extension HomeViewController: CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mode = .showAllStation
        nearbyTableView.reloadData()
        nearbyView.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard !searchText.isEmpty else {
            mode = .showAllStation
            nearbyTableView.reloadData()
            return
        }
        searchResults = allStationsArray.filter{(filterArray) -> Bool in
            guard let words = searchBar.text else { return false }
            return (filterArray.Position?.contains(words))!
        }
        mode = .showSearchResult
        nearbyTableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        locationSearchBar.resignFirstResponder()
        nearbyView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        locationSearchBar.resignFirstResponder()
        nearbyView.isHidden = true
    }
    
//    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        return true
//    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        return self.infoWindowView
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.requestLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let currentLocation = locations[0] as CLLocation;
        
        
        for item in self.stations {
            
            let coordinate1 = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let coordinate2 = CLLocation(latitude: Double(item.Y!), longitude: Double(item.X!))
            
            let distanceInMeters = coordinate2.distance(from: coordinate1)
            
            if distanceInMeters < 1500 {
                
                print(distanceInMeters)
                let nearbyStations = ALLiBike.init(X: Double(item.X!), Y: Double(item.Y!), Position: String(item.Position!), CAddress: String(item.CAddress!), AvailableCNT: item.AvailableCNT!, EmpCNT: item.EmpCNT!, UpdateTime: String(item.UpdateTime!))
                nearbyStationsArray.append(nearbyStations)
                
            }
        }
        
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
