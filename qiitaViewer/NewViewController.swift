//
//  NewViewController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/03/30.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import UIKit
import WebKit

    class NewViewController: UIViewController,WKUIDelegate{
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
        }
        
        var webView:WKWebView!
        var topPadding:CGFloat = 0
        var url:String!
        
        override func loadView() {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame:.zero,configuration: webConfiguration)
            webView.uiDelegate = self
            view = webView
        }
    
    override func viewDidAppear(_ animated: Bool) {
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        if #available(iOS 11.0, *){
            let window = UIApplication.shared.keyWindow
             topPadding = window!.safeAreaInsets.top
        }
        let rect = CGRect(x: 0,
                          y: topPadding,
                          width: screenWidth,
                          height: screenHeight - topPadding)
        
        let webConfiguration = WKWebViewConfiguration()
         webView = WKWebView(frame:rect,configuration: webConfiguration)
        
        let webUrl = URL(string: url)!
        let myRequest = URLRequest(url:webUrl)
        webView.load(myRequest)
        
        self.view.addSubview(webView)
        
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

