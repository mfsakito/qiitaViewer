    //
    //  Article.swift
    //  qiitaViewer
    //
    //  Created by 古賀旺人 on 2019/04/13.
    //  Copyright © 2019 古賀旺人. All rights reserved.
    //
    
    import Foundation
    
    class Article {
        var title:String
        var url:String
        var userId:String
        var profileImg:String
        
        init(title:String = "",url:String = "",userId:String = "",profileImg:String = "")
        {
            self.title = title
            self.url = url
            self.userId = userId
            self.profileImg = profileImg
        }                
        
    }
