//
//  ViewController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/03/26.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

//https://teratail.com/questions/154746
//↑サムネ表示はこれでできるか。。。？(Swiftで通信後TableViewCellに画像表示できない)



import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

var articles:[[String:String?]] = []

func getArticles(){
    let _ = Alamofire.request("https://qiita.com/api/v2/items").responseJSON{
        response in
        guard let object = response.result.value else {
            return
        }
        
        let json = JSON(object)
        json.forEach {(_,json) in
            let article:[String:String?] = [
            "title":json["title"].string,
            "url":json["url"].string,
            "userId":json["user"]["id"].string,
            "profile_img":json["user"]["profile_image_url"].string
            ]
            self.articles.append(article)
            print(self.articles)
        }
    self.articleTableView.reloadData()
    }
    
}

    var selectUrl: String!
//    cellがタップされたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newArticle = articles[indexPath.row]
        selectUrl = newArticle["url"]!
        performSegue(withIdentifier: "toNewViewController", sender: nil)
    }
//    画面遷移のとき
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let NVC:NewViewController = (segue.destination as? NewViewController)!
        NVC.url = selectUrl
    }
    
    @IBOutlet weak var articleTableView: UITableView!
    
    //TableViewに表示させるもの
    func tableView(_ tableView:UITableView,numberOfRowsInSection section :Int) -> Int{
        return articles.count
    }
    
    //tableViewCellの内容
    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style:.subtitle,reuseIdentifier:"cell")
        let article = articles[indexPath.row]
        cell.imageView?.image = UIImage(named: "logo.png")
        cell.textLabel?.text = article["title"]!
        cell.detailTextLabel?.text = article["userId"]!


//ココから。サムネの初期値はいれられたので、非同期で画像をためていきたい。
//        https://qiita.com/ytakzk/items/5b9655ab5c0825dbbd62
//        https://1000ch.net/posts/2016/dispatch-queue.html
//        DispatchQueue.global().async{
//            let url:NSURL = NSURL(article["profile_img"])
//        }
//
        
        

        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getArticles()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
//    model化。30行目付近のjsonの管理に関わる。
//    別ファイルに分けたほうがいいかも。

//    class Article:NSObject{
//        var title:String,url:String,userId:String,profileImg:String
//
//        init(title:String,url:String,userId:String,profileImg:String)
//        {
//        self.title = title
//        self.url = url
//        self.userId = userId
//        self.profileImg = profileImg
//        }
//
//    }
    
}

