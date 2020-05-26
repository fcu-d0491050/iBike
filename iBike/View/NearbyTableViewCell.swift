//
//  nearbyTableViewCell.swift
//  iBike
//
//  Created by 翟靖庭 on 18/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit

class NearbyTableViewCell: UITableViewCell {

    @IBOutlet weak var stationNameButton: UIButton!
    @IBOutlet weak var iBikeImageView: UIImageView!
    @IBOutlet weak var iBikeLabel: UILabel!
    @IBOutlet weak var parkingImageView: UIImageView!
    @IBOutlet weak var parkingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
