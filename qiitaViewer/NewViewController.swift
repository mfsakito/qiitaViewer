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
            if searchFavoritedArticle(key:url) == true{
                changeFavotiteButton(key: true)
            }else{
                changeFavotiteButton(key: false)
            }
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
                print("article has already favorited")
                return true
            }else{
                print("article favorited")
                return false
            }
        }
        
        func changeFavotiteButton(key:Bool){
            if key == true{
            rightFavoriteBarButtonItem = UIBarButtonItem(image: UIImage(named: "starred.png")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(articleFavoriteButtonTapped(_:)))
            }else{
                rightFavoriteBarButtonItem = UIBarButtonItem(image: UIImage(named: "star.png")!.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(articleFavoriteButtonTapped(_:)))
            }
            self.navigationItem.setRightBarButton(rightFavoriteBarButtonItem, animated: true)
        }
        
        func addArticleFavorite(){
            if searchFavoritedArticle(key:url) == true{
                if let article = realm.object(ofType: FavoriteArticleItem.self, forPrimaryKey: url){
                    
                try! realm.write {
                    realm.delete(article)
                    }
                    
                }
                changeFavotiteButton(key:false)
            }else {
                favoriteArticleUrlList.articleUrl = url
                
                try! realm.write {
                    realm.add(favoriteArticleUrlList)
                }
                changeFavotiteButton(key:true)
            }
        }
        
//        テスト用、データの表示
        func displayFavoritedArticles(){
            let fav = realm.objects(FavoriteArticleItem.self)
            for i in fav{
                print("url:\(i.articleUrl)")
                }
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

