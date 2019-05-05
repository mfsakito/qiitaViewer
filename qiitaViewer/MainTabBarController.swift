//
//  TabBarController.swift
//  qiitaViewer
//
//  Created by 古賀旺人 on 2019/04/28.
//  Copyright © 2019 古賀旺人. All rights reserved.
//

import UIKit

class MainTabBarController:UITabBarController,UITabBarControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        self.selectedIndex = 0
    }
    
    
    private func setupViewControllers(){
        self.viewControllers = [UIViewController(), UIViewController()]
        setTabItems()
    }
    private func setTabItems(){
        // タブで表示するViewControllerを配列に格納
        let tabItems:[MainTabBarItems] = [.main,.favorite]
        for (index, tabItem) in tabItems.enumerated() {
            setVC(tabItem:  tabItem, tabIndex: index)
        }
    }
    
    // self.viewControllersの配列の該当のindexにviewcontrollerをセットする
    private func setVC(tabItem:MainTabBarItems,tabIndex:Int){
        if let VC = tabItem.getVC(){
            self.viewControllers?[tabIndex] = VC
        }
        
    }
    
    
    /*
     mainView = UINavigationController(rootViewController: MainViewController())
     favoriteView = UINavigationController(rootViewController: FavoriteViewController())
     
     //表示するtabBarItemを指定
     mainView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.recents, tag: 1)
     favoriteView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.bookmarks, tag: 2)
     
     //        self.setViewControllers(myTabs, animated: false)
     
     */
    
    //UITabBarControllerの子のViewControllerは、自身が表示されるまで初期化されないようなので、自分で初期化処理を呼ぶ必要があります。ここにその方法を書きます。
    //    https://qiita.com/noobar/items/04266237ee625ec78260
    /*
     func tabBarNavViewSetUp(){
     
     for navViewController in self.viewControllers! {
     //            _ = navViewController.view
     print(navViewController.children[0])
     _ = navViewController.children[0].view
     }
     self.tabBarController?.selectedIndex = 1
     
     }
     
     
     */
    
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
