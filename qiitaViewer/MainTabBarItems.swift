//
//  MainTabBarItems.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/04/30.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import Foundation
import UIKit

enum MainTabBarItems {
    case main
    case favorite
    
    func getVC() -> UIViewController? {
        switch self {
        case .main:
            return UIStoryboard(name:"Main", bundle: nil).instantiateInitialViewController()
        case .favorite:
            return UIStoryboard(name:"Favorite", bundle: nil).instantiateInitialViewController()
        }
    }
    
    func getTabIndex() -> Int {
        switch self {
        case .main:
            return 0
        case .favorite:
            return 1
            
        }
    }
    func getTabTitle() -> String {
        switch self {
        case .main:
            return "ホーム"
        case .favorite:
            return "お気に入り"
        }
    }
}


