//
//  ZQRootViewController.swift
//  ZQPopupMenu
//
//  Created by Darren on 2019/4/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQPopupMenu

class ZQRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "try to touch the view"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Custom", style: .done, target: self, action: #selector(actionForRightBarButtonItem))
    }
    
    fileprivate lazy var config:ZQPopupMenuConfig = {
        let config = ZQPopupMenuConfig()
        let backConfig = ZQPopupMenuBackConfig()
        backConfig.backColor = UIColor.black
        backConfig.borderColor = UIColor.red
        backConfig.borderWidth = 1
        let itemConfig = ZQPopupMenuItemConfig()
        itemConfig.titlesArr = ["图片", "音乐", "运动", "新闻", "视频"] as [AnyObject]
        itemConfig.imagesArr = ["图片", "音乐", "运动", "新闻", "视频"] as [AnyObject]
        itemConfig.textColor = UIColor.red
        itemConfig.maxVisibleCount = 4
        let arrowConfig = ZQPopupMenuArrowConfig()
        config.backConfig = backConfig
        config.itemConfig = itemConfig
        config.arrowConfig = arrowConfig
        return config
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = event?.allTouches?.first?.location(in: view)
        config.backConfig.showPoint = point ?? CGPoint.zero
        ZQPopupMenu.showMenu(with: config, delegate: self)
    }
}

extension ZQRootViewController {
    @objc fileprivate func actionForRightBarButtonItem() {
        navigationController?.pushViewController(ZQCustomViewController(), animated: true)
    }
}

extension ZQRootViewController : ZQPopupMenuDelegate {
    func didSelected(popMenu: ZQPopupMenu, index: NSInteger) {
        print("--__--|| index___\(index)")
    }
}
