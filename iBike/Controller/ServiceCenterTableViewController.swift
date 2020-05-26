//
//  ServiceCenterTableViewController.swift
//  iBike
//
//  Created by 翟靖庭 on 15/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit

class ServiceCenterTableViewController: UITableViewController {
    
    @IBOutlet var serviceCenterTableView: UITableView!
    
    var information = [ALLiBike]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showServiceCenter()
        let nib = UINib(nibName: "ServiceCenterTableViewCell", bundle: nil)
        serviceCenterTableView.register(nib, forCellReuseIdentifier: "serviceCenterCell")
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return information.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCenterCell") as? ServiceCenterTableViewCell else {return UITableViewCell()}
        
        cell.stationLabel.text = information[indexPath.row].Position!
        cell.addressLabel.text = information[indexPath.row].CAddress!
        cell.ImageView.image = UIImage(named: "compass.png")
        cell.availableLabel.text = "可借車輛：\(String(information[indexPath.row].AvailableCNT!))"
        cell.emptyLabel.text = "可停空位：\(String(information[indexPath.row].EmpCNT!))"
        cell.updateLabel.text = "時間：\(information[indexPath.row].UpdateTime!)"
        
        return cell
    }
    
    func showServiceCenter() {
        guard let iBikeURL = URL(string: "http://e-traffic.taichung.gov.tw/DataAPI/api/YoubikeAllAPI") else { return }
        
        /*上傳下載資料*/
        URLSession.shared.dataTask(with: iBikeURL) { (data, response, error) in
            
            if error == nil {
                do {
                    self.information = try JSONDecoder().decode([ALLiBike].self, from: data!)
                    
                    /*讓更新的Code在Main Thread下執行*/
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
                    
                catch {
                    print("Error")
                }
            }
            
        }.resume()
    }
    
}
