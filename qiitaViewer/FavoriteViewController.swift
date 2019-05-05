//
//  FavoriteViewController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/04/28.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class FavoriteViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    var requestUrlList:Array<String> = []
    var searchAPIUrlList:Array<String> = []
    var favoriteArticleDataArray = [Article]()
    var imageCache = NSCache<AnyObject, AnyObject>()
    let entrySearchUrl = "https://qiita.com/api/v2/items/"
    @IBOutlet weak var favoritedArticleTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritedArticleTableView.delegate = self
        favoritedArticleTableView.dataSource = self
        preparingArticleData()
        // Do any additional setup after loading the view.
        //        お気に入りした記事のデータを取得する
        self.favoritedArticleTableView.reloadData()
    }
    
    
    //    -----------------------------------
    //      tableviewへの書き込み処理
    //    -----------------------------------
    
    //    うごいてない
    
    //TableViewに表示させるもの
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("お気に入り記事数 : \(favoriteArticleDataArray.count)")
        return favoriteArticleDataArray.count
    }
    

    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        print("tableViewへの書き込み開始")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //                let cell = UITableViewCell(style:.subtitle,reuseIdentifier:"cell")
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
    //    APIにお気に入りした記事の問い合わせ
    //    -----------------------------------
    
    //    realmからお気に入りしたURLのリストをつくる
    func createFavoritedArticlesList() -> Array<String>{
        let realm = try! Realm()
        let fav = realm.objects(FavoriteArticleItem.self)
        for i in fav{
            searchAPIUrlList.append(i.articleUrl)
        }
        //        print("createFavoritedArticlesList : \(searchAPIUrlList.count)")
        return searchAPIUrlList
    }
    
    //記事のIDを抽出する
    func extractArticleId() -> Array<String>{
        var idList:Array<String> = []
        let favoritedUrlList:Array<String> = createFavoritedArticlesList()
        for i in favoritedUrlList{
            let url:NSString = i as NSString
            let loc:Int = url.range(of: "items/").location
            let id = i[i.index(i.startIndex, offsetBy: loc + 6)...]
            idList.append(String(id))
        }
        //        print("extractArticleId : \(idList[0])")
        return idList
    }
    
    //    APIにリクエストするURLのリストを返す
    func createRequestUrlList() -> Array<String>{
        let favoritedIdList = extractArticleId()
        for i in favoritedIdList{
            requestUrlList.append(entrySearchUrl + i)
        }
        print("createRequestUrlList.count : \(requestUrlList.count)")
        return requestUrlList
    }
    
    //    記事ごとのデータを取り込む機構をつくる
    func returnFavoritedArticleData(requestUrl:String){
        DispatchQueue.global().async{
            print("start returnFavoritedArticleData")
            let _ = Alamofire.request(requestUrl).responseJSON{
                response in
                guard let object = response.result.value else {
                    return
                }
                let json:JSON = JSON(object)
                //            print(json)
                let article = Article()
                if let title = json["title"].string{
                    article.title = title}
                if let url = json["url"].string {
                    article.url = url }
                if let userId = json["user"]["id"].string {
                    print(userId)
                    article.userId = userId
                }
                if let profileImg = json["user"]["profile_image_url"].string {
                    article.profileImg = profileImg}
                DispatchQueue.main.async {
                    self.favoriteArticleDataArray.append(article)
                }
            }
        }
    }
    
    //    forの回転が遅く、他の部分の処理が並行して走っている？
    //    https://qiita.com/koji-nishida/items/14fda04b586263a47e73
    func preparingArticleData(){
        DispatchQueue.global().async {
            print("start preparingArticleData")
            self.createRequestUrlList()
            for url in self.requestUrlList{
                self.returnFavoritedArticleData(requestUrl: url)
                usleep(500000)
                DispatchQueue.main.async {
                    print("end preparingArticleData")
                    print("preparingArticleData：\(self.favoriteArticleDataArray.count)")
                    self.favoritedArticleTableView.reloadData()
                }
            }
            
        }
        
        
    }
    
    
    
    func getArticles(){
        
        print("start get articles")
        preparingArticleData()
        self.favoritedArticleTableView.reloadData()
        print("end get articles")
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
