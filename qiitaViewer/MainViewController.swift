//
//  ViewController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/03/26.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class MainViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    var articleDataArray = [Article]()
    var imageCache = NSCache<AnyObject, AnyObject>()
    private weak var refreshControl:UIRefreshControl!
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    //    let mainTabBarController = MainTabBarController()
    
    let entryUrl = "https://qiita.com/api/v2/items"
    
    func getArticles(queryUrl:String){
        print("api start")
        let _ = Alamofire.request(queryUrl).responseJSON{
            response in
            guard let object = response.result.value else {
                return
            }
            let json = JSON(object)
            self.articleDataArray = [Article]()
            json.forEach {(_,json) in
                let article = Article()
                if let title = json["title"].string{
                    article.title = title}
                if let url = json["url"].string {
                    article.url = url }
                if let userId = json["user"]["id"].string {
                    article.userId = userId}
                if let profileImg = json["user"]["profile_image_url"].string {
                    article.profileImg = profileImg}
                self.articleDataArray.append(article)
                
            }
            self.articleTableView.reloadData()            
        }
        
    }
    
    var selectUrl: String!
    //    cellがタップされたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newArticle = articleDataArray[indexPath.row]
        selectUrl = newArticle.url
        performSegue(withIdentifier: "toNewViewController", sender: nil)
    }
    //    画面遷移のとき
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let NVC:NewViewController = (segue.destination as? NewViewController)!
        NVC.url = selectUrl
    }
    
    
    
    //TableViewに表示させるもの
    func tableView(_ tableView:UITableView,numberOfRowsInSection section :Int) -> Int{
               print(articleDataArray.count)
        return articleDataArray.count
        
    }
    
    //tableViewCellの内容
    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style:.subtitle,reuseIdentifier:"cell")
        let article = articleDataArray[indexPath.row]
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        検索の操作を引き継ぐ
        //        MainTabBarController.tabBar.delegate = self
        searchBar.delegate = self
        
        //        新着記事の取得
        getArticles(queryUrl:entryUrl)
        
        // Do any additional setup after loading the view, typically from a nib.
        initializePullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        refresh()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //    商品検索
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar){
        //        入力テキストの取得
        let inputText = searchBar.text
        //        入力が0文字以上のチェック
        guard let searchQuery = inputText else {
            return
        }
        if searchQuery.lengthOfBytes(using: String.Encoding.utf8) > 0{
            print(searchQuery)
            //            表示している記事を一旦消す
            articleDataArray.removeAll()
            //            パラメータを指定する
            let requestUrl = createRequestUrl(parameter: searchQuery)
            getArticles(queryUrl:requestUrl)
            
        }
        searchBar.resignFirstResponder()
    }
    
    //    検索用のURLをつくる関数
    func createRequestUrl(parameter:String?) -> String{
        var query = ""
        if let value = parameter{
            if let escapedValue = value.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed){
                query = escapedValue
            }
        }
        
        let requestUrl = entryUrl + "?query=title%3A" + query
        print(requestUrl)
        return requestUrl
    }
    
    
    //    pull to refresh
    
    
    private func initializePullToRefresh(){
        let control = UIRefreshControl()
        control.addTarget(self,action:#selector(onPullToRefresh(_:)),for:.valueChanged)
        self.articleTableView.addSubview(control)
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
        getArticles(queryUrl: entryUrl)
        self.completeRefresh()
    }
    
    private func completeRefresh(){
        stopPullToRefresh()
    }
    
}

