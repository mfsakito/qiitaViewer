//
//  FavoriteViewController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/04/28.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    var favoriteArticleDataArray = [Article]()
    var imageCache = NSCache<AnyObject, AnyObject>()
    private weak var refreshControl:UIRefreshControl!
    @IBOutlet weak var favoritedArticleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritedArticleTableView.delegate = self
        favoritedArticleTableView.dataSource = self
//        preparingArticleData()
        // Do any additional setup after loading the view.
        //        お気に入りした記事のデータを取得する
        favoritedArticleFromRealm()
        initializePullToRefresh()
    }
    
    
    //    -----------------------------------
    //      tableviewへの書き込み処理
    //    -----------------------------------
    
    //TableViewに表示させるもの
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("お気に入り記事数 : \(favoriteArticleDataArray.count)")
        return favoriteArticleDataArray.count
    }
    

    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let cell = UITableViewCell(style:.subtitle,reuseIdentifier:"cell")
        let article = favoriteArticleDataArray[indexPath.row]
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.userId
        cell.imageView?.image = UIImage(named: "logo.png")
        
        //サムネの初期値はいれられたので、非同期で画像をためていく
        
        if let cacheImage = imageCache.object(forKey: article.profileImg as AnyObject) as? UIImage{
            cell.imageView?.image = cacheImage
        }else{
            
            let session = URLSession.shared
            
            if let url = URL(string: article.profileImg){
                let request = URLRequest(url: url as URL)
                
                let task = session.dataTask(with: request,completionHandler: {
                    (data:Data?,URLResponse:URLResponse?,error:Error?) -> Void in
                    
                    if let data = data {
                        
                        if let image = UIImage(data:data){
                            
                            self.imageCache.setObject(image, forKey: article.profileImg as AnyObject)
                            
                            DispatchQueue.main.async {
                                
                                cell.imageView?.image = image
                            }
                        }
                    }
                })
                task.resume()
            }
        }
        
        return cell
    }
    
    
    
    //    -----------------------------------
    //    お気に入り舌記事をrealmからとってくる
    //    -----------------------------------
    
    
    func favoritedArticleFromRealm(){
        let realm = try! Realm()
        let fav = realm.objects(FavoriteArticleItem.self)
        
        for i in fav{
            let articleList = Article()
            if Optional.some(i.articleUrl) != nil{
                articleList.url = i.articleUrl
            }
            if Optional.some(i.articleTitle) != nil{
                articleList.title = i.articleTitle
            }
            if Optional.some(i.userId) != nil{
                articleList.userId = i.userId
            }
            if Optional.some(i.profileImg) != nil{
                articleList.profileImg = i.profileImg}
            self.favoriteArticleDataArray.append(articleList)
            }
        self.favoritedArticleTableView.reloadData()
    }
    
    var selectUrl: String!
    //    cellがタップされたとき

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newArticle = favoriteArticleDataArray[indexPath.row]
        selectUrl = newArticle.url
        performSegue(withIdentifier: "toFavoriteViewController", sender: nil)
    }
    //    画面遷移のとき
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let NVC:NewViewController = (segue.destination as? NewViewController)!
        NVC.url = selectUrl
    }
    
    
    
//pull to refresh
    
    private func initializePullToRefresh(){
        let control = UIRefreshControl()
        control.addTarget(self,action:#selector(onPullToRefresh(_:)),for:.valueChanged)
        self.favoritedArticleTableView.addSubview(control)
        refreshControl = control
        
    }
    @objc private func onPullToRefresh(_ sender:AnyObject){
        refresh()
    }
    
    private func stopPullToRefresh(){
        if refreshControl.isRefreshing{
            refreshControl.endRefreshing()
        }
    }
    
    
    private func refresh(){
        favoriteArticleDataArray.removeAll()
        favoritedArticleFromRealm()
        self.completeRefresh()
    }
    
    private func completeRefresh(){
        stopPullToRefresh()
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
