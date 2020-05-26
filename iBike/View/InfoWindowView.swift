//
//  InfoWindowView.swift
//  iBike
//
//  Created by 翟靖庭 on 21/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit
import GoogleMaps

class InfoWindowView: UIView {
    
    var stations = [ALLiBike]()
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bikeCountLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var bikeImageView: UIImageView!
    @IBOutlet weak var routeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView() -> InfoWindowView {
        let infoWindowView = Bundle.main.loadNibNamed("InfoWindowView", owner: self, options: nil)?[0] as! InfoWindowView
        
        for item in self.stations {
                        
            let information = ALLiBike.init(X: Double(item.X!), Y: Double(item.Y!), Position: String(item.Position!), CAddress: String(item.CAddress!), AvailableCNT: item.AvailableCNT!, EmpCNT: item.EmpCNT!, UpdateTime: String(item.UpdateTime!))
            
            infoWindowView.stationNameLabel.text = String(information.Position!)
            infoWindowView.addressLabel.text = String(information.CAddress!)
            infoWindowView.bikeCountLabel.text = String(information.AvailableCNT!)
            infoWindowView.bikeImageView.image = UIImage(named: "showiBikeMarker")
            
            
        }
        return infoWindowView
    }
    
}
