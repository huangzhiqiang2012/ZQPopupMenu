//
//  ZQCustomViewController.swift
//  ZQPopupMenuDemo
//
//  Created by Darren on 2019/4/12.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQPopupMenu

class ZQCustomPopMenuTableViewCell: UITableViewCell {
    
    lazy var titleLabel:UILabel = {
        let titleLabel:UILabel = UILabel()
        titleLabel.backgroundColor = UIColor.blue
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.red
        titleLabel.layer.cornerRadius = 5
        titleLabel.layer.masksToBounds = true
        return titleLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        contentView.addSubview(titleLabel)
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: (contentView.frame.size.height - 20) * 0.5, width: contentView.frame.size.width - 30, height: 20)
    }
}

class ZQCustomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "try to touch the view"
    }
    
    fileprivate lazy var dataArr:[String] = {
        var dataArr:[String] = [String]()
        for i:Int in 0..<10 {
            dataArr.append("custom cell \(i)")
        }
        return dataArr
    }()
    
    fileprivate lazy var config:ZQPopupMenuConfig = {
        let config = ZQPopupMenuConfig()
        let backConfig = ZQPopupMenuBackConfig()
        backConfig.backColor = UIColor.black
        backConfig.borderColor = UIColor.red
        backConfig.borderWidth = 1
        config.backConfig = backConfig
        let itemConfig = ZQPopupMenuItemConfig()
        itemConfig.customCellNumber = dataArr.count
        config.itemConfig = itemConfig
        return config
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = event?.allTouches?.first?.location(in: view)
        config.backConfig.showPoint = point ?? CGPoint.zero
        let popMenu = ZQPopupMenu(config: config)
        popMenu.delegate = self
        popMenu.show()
    }
}

extension ZQCustomViewController : ZQPopupMenuDelegate {
    func cellForRow(popMenu: ZQPopupMenu, index: NSInteger) -> UITableViewCell {
        var cell = popMenu.tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ZQCustomPopMenuTableViewCell.self))
        if cell == nil {
            cell = ZQCustomPopMenuTableViewCell(style: .default, reuseIdentifier: NSStringFromClass(ZQCustomPopMenuTableViewCell.self))
            (cell as! ZQCustomPopMenuTableViewCell).titleLabel.textAlignment = index % 2 == 0 ? .center : .left
            (cell as! ZQCustomPopMenuTableViewCell).titleLabel.text = dataArr[index]
        }
        return cell!
    }
}
