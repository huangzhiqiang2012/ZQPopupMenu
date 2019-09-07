//
//  ZQPopupMenuConfig.swift
//  ZQPopupMenu
//
//  Created by Darren on 2019/4/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 箭头方向
public enum ZQPopupMenuArrowDirection:Int {
    case top          = 0    ///< 向上
    case bottom       = 1    ///< 向下
    case left         = 2    ///< 向左
    case right        = 3    ///< 向右
    case none         = 4    ///< 无
}

// MARK: 箭头方向优先级 当控件超出屏幕时会自动调整成反方向
public enum ZQPopupMenuArrowPriorityDirection:Int {
    case top          = 0    ///< 向上
    case bottom       = 1    ///< 向下
    case left         = 2    ///< 向左
    case right        = 3    ///< 向右
    case none         = 4    ///< 无
}

// MARK: 配置信息对象 - 背景
public class ZQPopupMenuBackConfig: NSObject {
    
    /// 显示的点坐标, 默认屏幕中心
    public var showPoint:CGPoint = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5)
    
    /// 背景颜色, 默认 UIColor.white
    public var backColor:UIColor = UIColor.white
    
    /// 边框颜色, 默认 UIColor.lightGray
    public var borderColor:UIColor = UIColor.lightGray
    
    /// 边框宽度, 默认 0.0
    public var borderWidth:CGFloat = 0.0
    
    /// 圆角半径, 默认 5.0
    public var cornerRadius:CGFloat = 5.0
    
    /// 自定义圆角, 默认 .allCorners 当自动调整方向时corner会自动转换至镜像方向
    public var rectCorner:UIRectCorner = .allCorners
    
    /// 是否显示阴影, 默认 true
    public var showShadow:Bool = true
    
    /// 阴影透明度, 默认 0.5
    public var shadowOpacity:CGFloat = 0.5
    
    /// 阴影偏移, 默认 CGSize(width: 2, height: 2)
    public var shadowOffset:CGSize = CGSize(width: 2, height: 2)
    
    /// 阴影圆角半径, 默认 2.0
    public var shadowRadius:CGFloat = 2.0
    
    /// 是否显示遮盖层, 默认 true
    public var showMaskView:Bool = true
    
    /// 遮盖层颜色, 默认 UIColor.black.withAlphaComponent(0.1)
    public var maskColor:UIColor = UIColor.black.withAlphaComponent(0.1)
    
    /// 选择菜单项后消失, 默认 true
    public var dismissOnSelected:Bool = true
    
    /// 点击背景后消失, 默认 true
    public var dismissOnTouchBack:Bool = true
    
    /// 距离最近的屏幕的最小距离, 默认 10
    public var minSpace:CGFloat = 10.0
    
    /// 动画时间, 默认 0.25
    public var animateDuration:CGFloat = 0.25
    
    /// 是否显示竖直滚动条, 默认 false
    public var showsVerticalScrollIndicator:Bool = false
    
    /// 是否显示水平滚动条, 默认 false
    public var showsHorizontalScrollIndicator:Bool = false
}

// MARK: 配置信息对象 - 箭头
public class ZQPopupMenuArrowConfig: NSObject {
    
    /// 箭头宽度, 默认 15
    public var arrowWidth:CGFloat = 15.0
    
    /// 箭头高度
    public var arrowHeight:CGFloat = 10.0
    
    /// 箭头位置, 默认是 0.0 -> 中间
    public var arrowPosition:CGFloat = 0.0
    
    /// 箭头方向, 默认 .top
    public var arrowDirection:ZQPopupMenuArrowDirection = .top
    
    /// 箭头优先方向, 默认 .top
    public var arrowPriorityDirection:ZQPopupMenuArrowPriorityDirection = .top
}

// MARK: 配置信息对象 - item
public class ZQPopupMenuItemConfig: NSObject {
    
    /// 标题, 对象是 NSString / NSAttributedString
    public var titlesArr:[AnyObject] = [AnyObject]()
    
    /// 字体
    public var font:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// 字体颜色 默认 UIColor.black
    public var textColor:UIColor = UIColor.black
    
    /// 图片, 对象是 NSString / UIImage
    public var imagesArr:[AnyObject] = [AnyObject]()
    
    /// 可见的最大行数, 默认 5
    public var maxVisibleCount:Int = 5
    
    /// item的高度, 默认 44
    public var itemHeight:CGFloat = 44.0
    
    /// item的高度, 默认 200
    public var itemWidth:CGFloat = 200.0
    
    /// 是否显示分割线, 默认 true
    public var showSeparator:Bool = true
    
    /// 分割线颜色, 默认 UIColor.lightGray
    public var separatorColor:UIColor = UIColor.lightGray
    
    /// 分割线的左右距离, 默认 0.0
    public var separatorSpace:CGFloat = 0.0
    
    /// 分割线的高, 默认 0.5
    public var separatorHeight:CGFloat = 0.5
}

// MARK: 配置信息对象
public class ZQPopupMenuConfig: NSObject {
    
    /// 背景设置
    public var backConfig:ZQPopupMenuBackConfig = ZQPopupMenuBackConfig()
    
    /// 箭头设置
    public var arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuArrowConfig()
    
    /// item设置
    public var itemConfig:ZQPopupMenuItemConfig = ZQPopupMenuItemConfig()
}
