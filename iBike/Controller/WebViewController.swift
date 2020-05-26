//
//  WebViewController.swift
//  iBike
//
//  Created by 翟靖庭 on 15/5/2020.
//  Copyright © 2020 ChaiChingTing. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        openWebView()
        
    }
    
    func openWebView() {
        
        if let iBikeUrl = URL(string: "https://i.youbike.com.tw/home") {
            let request = URLRequest(url: iBikeUrl)
            webView.load(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
