//
//  NewViewController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/03/30.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

    class NewViewController: UIViewController,WKUIDelegate{
        
        var webView:WKWebView!
        var topPadding:CGFloat = 0
        var url:String!
        var rightFavoriteBarButtonItem:UIBarButtonItem!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
//            お気に入りボタンの設置
            rightFavoriteBarButtonItem = UIBarButtonItem(image: UIImage(named: "star.png")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(articleFavoriteButtonTapped(_:)))
            // Do any additional setup after loading the view.
            self.navigationItem.setRightBarButton(rightFavoriteBarButtonItem, animated: true)
        }
        
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
        
        
//        記事お気に入り
        
        @objc func articleFavoriteButtonTapped(_ sender:UIBarButtonItem){
            //            print(url!)
            
            addArticleFavorite()
            
            displayFavoritedArticles()
        }
        
//        ボタンを押すとデータをためる
        var favoriteArticleUrlList = FavoriteArticleItem()
        let realm = try! Realm()
        
        func searchFavoritedArticle(key:String) -> Bool {
            if let _ = realm.object(ofType: FavoriteArticleItem.self, forPrimaryKey: key){
                return true
            }else{
                return false
            }
        }
        
        func addArticleFavorite(){
            if searchFavoritedArticle(key:url) == true{
                rightFavoriteBarButtonItem = UIBarButtonItem(image: UIImage(named: "starred.png")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(articleFavoriteButtonTapped(_:)))
            }else {
                favoriteArticleUrlList.articleUrl = url
                //            let fav = realm.objects(FavoriteArticleItem.self)
                
                try! realm.write {
                    realm.add(favoriteArticleUrlList)
                }
            }
        }
        
//        テスト用、データの表示
        func displayFavoritedArticles(){
            let fav = realm.objects(FavoriteArticleItem.self)
            for i in fav{
                print("url:\(i.articleUrl)")
                }
        }
//       データがあればお気に入りボタンを変更する
        
//        お気に入り状態で再タップするとデータを削除する
        
//        (できれば)お気に入りした記事リスト
        
        
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

