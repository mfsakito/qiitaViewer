//
//  favoriteArticleItm.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/04/27.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteArticleItem:Object {
    @objc dynamic var articleUrl:String = ""
    @objc dynamic var articleTitle:String = ""
    
//    init(articleUrl:String = "",articleTitle:String = ""){
//        self.articleUrl = articleUrl
//        self.articleTitle = articleTitle
//    }
}
