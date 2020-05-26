//
//  MenuViewController.swift
//  iBike
//
//  Created by 翟靖庭 on 17/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case 場站地圖
    case 服務中心
    case 官方網站
    case 車友集結
    
}

class MenuViewController: UITableViewController {

    var tapMenuType: ((MenuType) -> Void)?
    
    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
      
  }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row)
            else {
                return
        }
        
        /*頁面跳轉*/
        dismiss(animated: true) { [weak self] in
            print("Dismissing: \(menuType)")
            self?.tapMenuType?(menuType)
        }
    }
    
}
