//
//  ServiceCenterTableViewCell.swift
//  iBike
//
//  Created by 翟靖庭 on 15/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit

class ServiceCenterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
