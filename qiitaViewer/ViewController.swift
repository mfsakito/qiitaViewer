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

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var articleDataArray = [Article]()
    var imageCache = NSCache<AnyObject, AnyObject>()
    private weak var refreshControl:UIRefreshControl!
    @IBOutlet weak var articleTableView: UITableView!
    
func getArticles(){
    let _ = Alamofire.request("https://qiita.com/api/v2/items").responseJSON{
        response in
        guard let object = response.result.value else {
            return
        }
        
        let json = JSON(object)
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
        print(self.articleDataArray)
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
        // Do any additional setup after loading the view, typically from a nib.
        getArticles()
        initializePullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
//    ここから。pulltorefreshを実行すると、古いcellが削除されず、どんどん積み重なってしまう。実機確認
    
    
    private func refresh(){
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
        

        self.completeRefresh()
    
    }
    
    private func completeRefresh(){
        stopPullToRefresh()
        getArticles()
    }
}

