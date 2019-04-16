//
//  ZQPopupMenu.swift
//  ZQPopupMenuDemo
//
//  Created by Darren on 2019/4/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: ZQPopupMenuTableViewCell
public class ZQPopupMenuTableViewCell: UITableViewCell {
    
    fileprivate lazy var separatorView:UIView = {
        let separatorView:UIView = UIView()
        return separatorView
    }()
    
    var index:Int?
    
    var itemConfig:ZQPopupMenuItemConfig? {
        didSet {
            if let info = itemConfig {
                if !info.showSeparator {
                    separatorView.isHidden = true
                    return
                }
                if let row = index {
                    if info.titlesArr[row].isKind(of: NSAttributedString.self) {
                       textLabel?.attributedText = (info.titlesArr[row] as! NSAttributedString)
                    }
                    else if info.titlesArr[row].isKind(of: NSString.self) {
                        textLabel?.textColor = info.textColor
                        textLabel?.font = info.font
                        textLabel?.text = info.titlesArr[row] as! NSString as String
                    }
                    else {
                        textLabel?.text = nil
                        textLabel?.attributedText = nil
                    }
                    
                    if info.imagesArr.count >= row + 1 {
                        if info.imagesArr[row].isKind(of: NSString.self) {
                            imageView?.image = UIImage(named: info.imagesArr[row] as! NSString as String)
                        }
                        else if info.imagesArr[row].isKind(of: UIImage.self) {
                            imageView?.image = (info.imagesArr[row] as! UIImage)
                        }
                        else {
                            imageView?.image = nil
                        }
                    }
                    else {
                        imageView?.image = nil
                    }
                    separatorView.frame = CGRect(x: info.separatorSpace, y: contentView.bounds.size.height - info.separatorHeight, width: contentView.bounds.size.width - 2 * info.separatorSpace, height: info.separatorHeight)
                    separatorView.backgroundColor = info.separatorColor
                    separatorView.isHidden = row == info.titlesArr.count - 1
                }
                else {
                    textLabel?.text = nil
                    textLabel?.attributedText = nil
                    imageView?.image = nil
                    separatorView.isHidden = true
                }
            }
        }
    }
    
    // MARK: life cycle
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension ZQPopupMenuTableViewCell {
    fileprivate func setupViews() {
        backgroundColor = UIColor.clear
        contentView.addSubview(separatorView)
        textLabel?.numberOfLines = 0
    }
}

// MARK: 代理
@objc public protocol ZQPopupMenuDelegate:NSObjectProtocol {
    
    @objc optional func willShow(popMenu:ZQPopupMenu)
    
    @objc optional func didShow(popMenu:ZQPopupMenu)
    
    @objc optional func willDismiss(popMenu:ZQPopupMenu)
    
    @objc optional func didDismiss(popMenu:ZQPopupMenu)
    
    @objc optional func didSelected(popMenu:ZQPopupMenu, index:NSInteger)
    
    @objc optional func cellForRow(popMenu:ZQPopupMenu, index:NSInteger) -> UITableViewCell
}

// MARK: 弹窗菜单视图
public class ZQPopupMenu: UIView {
    
    /// 配置信息
    fileprivate var config:ZQPopupMenuConfig?
    
    /// 是否需要改变箭头方向
    fileprivate var changeArrowDirection:Bool = false
    
    /// 屏幕宽
    fileprivate let screenWidth:CGFloat = UIScreen.main.bounds.size.width
    
    /// 屏幕高
    fileprivate let screenHeight:CGFloat = UIScreen.main.bounds.size.height
    
    /// 内容高度
    fileprivate var contentHeight:CGFloat = 0.0
    
    /// cell个数
    fileprivate var cellCount:Int = 0
    
    fileprivate lazy var backView:UIView = {
        let backView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        if let config = config {
            backView.backgroundColor = config.backConfig.maskColor
        }
        backView.alpha = 0
        backView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionForBackView))
        backView.addGestureRecognizer(tap)
        return backView
    }()
    
    fileprivate lazy var dataTableView:UITableView = {
        let dataTableView:UITableView = UITableView(frame: CGRect.zero, style: .plain)
        dataTableView.backgroundColor = UIColor.clear
        dataTableView.tableFooterView = UIView()
        dataTableView.separatorStyle = .none
        if let config = config {
            dataTableView.rowHeight = config.itemConfig.itemHeight
            dataTableView.showsVerticalScrollIndicator = config.backConfig.showsVerticalScrollIndicator
            dataTableView.showsHorizontalScrollIndicator = config.backConfig.showsHorizontalScrollIndicator
        }
        dataTableView.delegate = self
        dataTableView.dataSource = self
        return dataTableView
    }()
    
    public var tableView:UITableView {
        get {
            return dataTableView
        }
    }
    
    public weak var delegate:ZQPopupMenuDelegate?
    
    // MARK: life cycle
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
    
    fileprivate convenience init(config:ZQPopupMenuConfig) {
        self.init()
        self.config = config
        setupViews()
    }
    
    public override var frame: CGRect {
        didSet {
            if let config = config {
                let backConfig:ZQPopupMenuBackConfig = config.backConfig
                let arrowConfig:ZQPopupMenuArrowConfig = config.arrowConfig
                let borderWidth:CGFloat = backConfig.borderWidth
                let arrowHeight:CGFloat = arrowConfig.arrowHeight
                switch arrowConfig.arrowDirection {
                case .top:
                    self.dataTableView.frame = CGRect(x: borderWidth, y: borderWidth + arrowHeight, width: frame.size.width - borderWidth * 2, height: frame.size.height - arrowHeight)
                    
                case .bottom:
                    self.dataTableView.frame = CGRect(x: borderWidth, y: borderWidth, width: frame.size.width - borderWidth * 2, height: frame.size.height - arrowHeight)
                    
                case .left:
                    self.dataTableView.frame = CGRect(x: borderWidth + arrowHeight, y: borderWidth, width: frame.size.width - borderWidth * 2 - arrowHeight, height: frame.size.height)
                    
                case .right:
                    self.dataTableView.frame = CGRect(x: borderWidth, y: borderWidth, width: frame.size.width - borderWidth * 2 - arrowHeight, height: frame.size.height)
                    
                case .none:break
                }
            }
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let config = config else {
            super.draw(rect)
            return
        }
        let bezierPath:UIBezierPath = UIBezierPath.creat(rect, config: config)
        bezierPath.fill()
        bezierPath.stroke()
    }
}

// MARK: public
public extension ZQPopupMenu {
    @discardableResult
    class func showMenu(with config:ZQPopupMenuConfig, delegate:ZQPopupMenuDelegate? = nil) -> ZQPopupMenu {
        let popMenu = ZQPopupMenu(config: config)
        popMenu.delegate = delegate
        popMenu.show()
        return popMenu
    }
    
    func dismiss() {
        guard let config = config else {
            return
        }
        delegate?.willDismiss?(popMenu: self)
        let backConfig:ZQPopupMenuBackConfig = config.backConfig
        UIView.animate(withDuration: TimeInterval(backConfig.animateDuration), animations: {
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
            self.alpha = 0
            self.backView.alpha = 0
        }) { (finish) in
            self.delegate?.didDismiss?(popMenu: self)
            self.delegate = nil
            self.backView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}

// MARK: private
extension ZQPopupMenu {
    
    fileprivate func setupViews() {
        guard let window = UIApplication.shared.keyWindow, let config = config else {
            return
        }
        let backConfig = config.backConfig
        if backConfig.showMaskView {
            window.addSubview(backView)
        }
        alpha = 0
        window.addSubview(self)
        addSubview(dataTableView)
    }
    
    fileprivate func updateUI() {
        guard let config = config else {
            return
        }
        
        /// 必须设置成UIColor.clear,不然重写的draw(_ rect: CGRect)方法里无效
        backgroundColor = UIColor.clear
        if config.backConfig.showShadow {
            layer.shadowOpacity = Float(config.backConfig.shadowOpacity)
            layer.shadowOffset = config.backConfig.shadowOffset
            layer.shadowRadius = config.backConfig.shadowRadius
        }
        updateArrow()
        updateFrame()
        dataTableView.reloadData()
        setNeedsDisplay()
    }
    
    fileprivate func updateArrow() {
        guard let config = config else {
            return
        }
        let itemConfig:ZQPopupMenuItemConfig = config.itemConfig
        let backConfig:ZQPopupMenuBackConfig = config.backConfig
        let arrowConfig:ZQPopupMenuArrowConfig = config.arrowConfig
        
        if let cell = delegate?.cellForRow?(popMenu: self, index: 0) {
            cellCount =  itemConfig.customCellNumber
        }
        else {
            cellCount = itemConfig.titlesArr.count
        }
        
        /// 计算内容总高度
        if cellCount > itemConfig.maxVisibleCount {
            contentHeight = itemConfig.itemHeight * CGFloat(itemConfig.maxVisibleCount) + backConfig.borderWidth * 2
            dataTableView.bounces = true
        }
        else {
            contentHeight = itemConfig.itemHeight * CGFloat(cellCount) + backConfig.borderWidth * 2
            dataTableView.bounces = false
        }
        
        /// 计算是否需要调整箭头方向
        let point:CGPoint = backConfig.showPoint
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let minSpace:CGFloat = backConfig.minSpace
        let itemWidth:CGFloat = itemConfig.itemWidth
        switch arrowConfig.arrowPriorityDirection {
        case .top:
            if point.y + contentHeight + arrowHeight > screenHeight - minSpace {
                arrowConfig.arrowDirection = .bottom
                changeArrowDirection = true
            }
            else {
                arrowConfig.arrowDirection = .top
                changeArrowDirection = false
            }
            
        case .bottom:
            if point.y - contentHeight - arrowHeight < minSpace {
                arrowConfig.arrowDirection = .top
                changeArrowDirection = true
            }
            else {
                arrowConfig.arrowDirection = .bottom
                changeArrowDirection = false
            }
            
        case .left:
            if point.x + itemWidth + arrowHeight > screenWidth - minSpace {
                arrowConfig.arrowDirection = .right
                changeArrowDirection = true
            }
            else {
                arrowConfig.arrowDirection = .left
                changeArrowDirection = false
            }
            
        case .right:
            if point.x - itemWidth - arrowHeight < minSpace {
                arrowConfig.arrowDirection = .left
                changeArrowDirection = true
            }
            else {
                arrowConfig.arrowDirection = .right
                changeArrowDirection = false
            }
            
        default:break
        }
        
        /// 计算箭头的位置
        switch arrowConfig.arrowDirection {
        case .top, .bottom:
            if point.x + itemWidth / 2 > screenWidth - minSpace {
                arrowConfig.arrowPosition = itemWidth - (screenWidth - minSpace - point.x)
            }
            else if point.x < itemWidth / 2 + minSpace {
                arrowConfig.arrowPosition = point.x - minSpace
            }
            else {
                arrowConfig.arrowPosition = itemWidth / 2
            }
            
        case .left, .right:
            if point.y + contentHeight / 2 > screenHeight - minSpace {
                arrowConfig.arrowPosition = contentHeight - (screenHeight - minSpace - point.y)
            }
            else if point.y < contentHeight / 2 + minSpace {
                arrowConfig.arrowPosition = point.y - minSpace
            }
            else {
                arrowConfig.arrowPosition = contentHeight / 2
            }
        default:break
        }
    }
    
    fileprivate func updateFrame() {
        guard let config = config else {
            return
        }
        let backConfig:ZQPopupMenuBackConfig = config.backConfig
        let arrowConfig:ZQPopupMenuArrowConfig = config.arrowConfig
        let itemConfig:ZQPopupMenuItemConfig = config.itemConfig
        let arrowPosition:CGFloat = arrowConfig.arrowPosition
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let itemWidth:CGFloat = itemConfig.itemWidth
        let minSpace:CGFloat = backConfig.minSpace
        let point:CGPoint = backConfig.showPoint
        
        switch arrowConfig.arrowDirection {
        case .top:
            if arrowPosition > itemWidth / 2 {
                self.frame = CGRect(x: screenWidth - minSpace - itemWidth, y: point.y, width: itemWidth, height: contentHeight + arrowHeight)
            }
            else if arrowPosition < itemWidth / 2 {
                self.frame = CGRect(x: minSpace, y: point.y, width: itemWidth, height: contentHeight + arrowHeight)
            }
            else {
                self.frame = CGRect(x: point.x - itemWidth / 2, y: point.y, width: itemWidth, height: contentHeight + arrowHeight)
            }
            
        case .bottom:
            let y = point.y - arrowHeight - contentHeight
            if arrowPosition > itemWidth / 2 {
                self.frame = CGRect(x: screenWidth - minSpace - itemWidth, y: y, width: itemWidth, height: contentHeight + arrowHeight)
            }
            else if arrowPosition < itemWidth / 2 {
                self.frame = CGRect(x: minSpace, y: y, width: itemWidth, height: contentHeight + arrowHeight)
            }
            else {
                self.frame = CGRect(x: point.x - itemWidth / 2, y: y, width: itemWidth, height: contentHeight + arrowHeight)
            }
            
        case .left:
            self.frame = CGRect(x: point.x, y: point.y - arrowPosition, width: itemWidth + arrowHeight, height: contentHeight)
        
        case .right:
            self.frame = CGRect(x: point.x - itemWidth - arrowHeight, y: point.y - arrowPosition, width: itemWidth + arrowHeight, height: contentHeight)

        default:break
        }
    }
    
    fileprivate func show() {
        guard let config = config else {
            return
        }
        delegate?.willShow?(popMenu: self)
        updateUI()
        let backConfig:ZQPopupMenuBackConfig = config.backConfig
        layer.setAffineTransform(CGAffineTransform(scaleX: 0.1, y: 0.1))
        UIView.animate(withDuration: TimeInterval(backConfig.animateDuration), animations: {
            self.layer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            self.backView.alpha = 1
            self.alpha = 1
        }) { (finish) in
            if finish {
                self.delegate?.didShow?(popMenu: self)
            }
        }
    }
}

extension ZQPopupMenu {
    @objc func actionForBackView() {
        guard let config = config else {
            return
        }
        if config.backConfig.dismissOnTouchBack {
            dismiss()
        }
    }
}

// MARK: UITableViewDelegate UITableViewDataSource
extension ZQPopupMenu:UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if delegate != nil {
            if let cell = delegate!.cellForRow?(popMenu: self, index: indexPath.row) {
                return cell
            }
        }
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ZQPopupMenuTableViewCell.self))
        if cell == nil {
            cell = ZQPopupMenuTableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: NSStringFromClass(ZQPopupMenuTableViewCell.self))
        }
        guard let config = config else {
            return cell!
        }
        let itemConfig = config.itemConfig
        (cell as! ZQPopupMenuTableViewCell).index = indexPath.row
        (cell as! ZQPopupMenuTableViewCell).itemConfig = itemConfig
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelected?(popMenu: self, index: indexPath.row)
        guard let config = config else {
            return
        }
        if config.backConfig.dismissOnSelected {
            dismiss()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let config = config else {
            return 0
        }
        return config.itemConfig.itemHeight
    }
}

// MARK: UIBezierPath + Extension
public extension UIBezierPath {
    class func creat(_ rect:CGRect, config:ZQPopupMenuConfig) -> UIBezierPath {
        let bezierPath:UIBezierPath = UIBezierPath()
        
        let backConfig:ZQPopupMenuBackConfig = config.backConfig
        let borderWidth:CGFloat = backConfig.borderWidth
        let rectCorner:UIRectCorner = backConfig.rectCorner
        let cornerRadius:CGFloat = backConfig.cornerRadius
        
        let arrowConfig:ZQPopupMenuArrowConfig = config.arrowConfig
        let arrowDirection:ZQPopupMenuArrowDirection = arrowConfig.arrowDirection
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let arrowWidthHalf:CGFloat = arrowConfig.arrowWidth / 2
        var arrowPosition:CGFloat = arrowConfig.arrowPosition
    
        bezierPath.lineWidth = borderWidth
        
        let x:CGFloat = borderWidth / 2
        let y:CGFloat = borderWidth / 2
        let width:CGFloat = rect.size.width - borderWidth
        let height:CGFloat = rect.size.height - borderWidth
        var topRightRadius:CGFloat = 0, topLeftRadius:CGFloat = 0, bottomRightRadius:CGFloat = 0, bottomLeftRadius:CGFloat = 0
        var topRightArcCenter:CGPoint = CGPoint.zero, topLeftArcCenter:CGPoint = CGPoint.zero, bottomRightArcCenter:CGPoint = CGPoint.zero, bottomLeftArcCenter:CGPoint = CGPoint.zero
        if (rectCorner.contains(UIRectCorner.topLeft)) {
            topLeftRadius = cornerRadius
        }
        if (rectCorner.contains(UIRectCorner.topRight)) {
            topRightRadius = cornerRadius
        }
        if (rectCorner.contains(UIRectCorner.bottomLeft)) {
            bottomLeftRadius = cornerRadius
        }
        if (rectCorner.contains(UIRectCorner.bottomRight)) {
            bottomRightRadius = cornerRadius
        }
        
        let pi_3_2:CGFloat = .pi * 3 / 2
        let pi_1_2:CGFloat = .pi / 2
        let pi_2:CGFloat = .pi * 2
        
        switch arrowDirection {
        case .top:
            topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: arrowHeight + topLeftRadius + x)
            topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y: arrowHeight + topRightRadius + x)
            bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x)
            bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                          y: height - bottomRightRadius + x)
            
            if arrowPosition < topLeftRadius + arrowWidthHalf {
                arrowPosition = topLeftRadius + arrowWidthHalf
            }
            else if arrowPosition > width - topRightRadius - arrowWidthHalf {
                arrowPosition = width - topRightRadius - arrowWidthHalf
            }
            bezierPath.move(to: CGPoint(x: arrowPosition - arrowWidthHalf, y: arrowHeight + x))
            bezierPath.addLine(to: CGPoint(x: arrowPosition, y: y + x))
            bezierPath.addLine(to: CGPoint(x: arrowPosition + arrowWidthHalf, y: arrowHeight + x))
            bezierPath.addLine(to: CGPoint(x: width - topRightRadius, y: arrowHeight + x))
            bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: 2 * .pi, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x))
            bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height + x))
            bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: .pi, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: x, y: arrowHeight + topLeftRadius + x))
            bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: .pi, endAngle: pi_3_2, clockwise: true)
            
        case .bottom:
            topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: topLeftRadius + x)
            topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y: topRightRadius + x)
            bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x - arrowHeight)
            bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x - arrowHeight)
            
            if arrowPosition < bottomLeftRadius + arrowWidthHalf {
                arrowPosition = bottomLeftRadius + arrowWidthHalf
            }
            else if arrowPosition > width - bottomRightRadius - arrowWidthHalf {
                arrowPosition = width - bottomRightRadius - arrowWidthHalf
            }
            bezierPath.move(to: CGPoint(x: arrowPosition + arrowWidthHalf, y: height - arrowHeight + x))
            bezierPath.addLine(to: CGPoint(x: arrowPosition, y: height + x))
            bezierPath.addLine(to: CGPoint(x: arrowPosition - arrowWidthHalf, y: height - arrowHeight + x))
            bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height - arrowHeight + x))
            bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: .pi, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: x, y: topLeftRadius + x))
            bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: .pi, endAngle: pi_3_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width - topRightRadius + x, y: x))
            bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x - arrowHeight))
            bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
            
        case .left:
            topLeftArcCenter = CGPoint(x: topLeftRadius + x + arrowHeight,
                                       y:  topLeftRadius + x)
            topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y:  topRightRadius + x)
            bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x + arrowHeight,
                                          y: height - bottomLeftRadius + x)
            bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x)
            
            if arrowPosition < topLeftRadius + arrowWidthHalf {
                arrowPosition = topLeftRadius + arrowWidthHalf
            }
            else if arrowPosition > height - bottomLeftRadius - arrowWidthHalf {
                arrowPosition = height - bottomLeftRadius - arrowWidthHalf
            }
            bezierPath.move(to: CGPoint(x: arrowHeight + x, y: arrowPosition + arrowWidthHalf))
            bezierPath.addLine(to: CGPoint(x: x, y: arrowPosition))
            bezierPath.addLine(to: CGPoint(x: arrowHeight + x, y: arrowPosition - arrowWidthHalf))
            bezierPath.addLine(to: CGPoint(x: arrowHeight + x, y: topLeftRadius + x))
            bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: .pi, endAngle: pi_3_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width - topRightRadius, y: x))
            bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x))
            bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: arrowHeight + bottomLeftRadius + x, y: height + x))
            bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: .pi, clockwise: true)
            
        case .right:
            topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: topLeftRadius + x)
            topRightArcCenter = CGPoint(x: width - topRightRadius + x - arrowHeight,
                                        y:  topRightRadius + x)
            bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x)
            bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x - arrowHeight,
                                           y: height - bottomRightRadius + x)
            
            if arrowPosition < topRightRadius + arrowWidthHalf {
                arrowPosition = topRightRadius + arrowWidthHalf
            }
            else if arrowPosition > height - bottomRightRadius - arrowWidthHalf {
                arrowPosition = height - bottomRightRadius - arrowWidthHalf
            }
            bezierPath.move(to: CGPoint(x: width - arrowHeight + x, y: arrowPosition - arrowWidthHalf))
            bezierPath.addLine(to: CGPoint(x: width + x, y: arrowPosition))
            bezierPath.addLine(to: CGPoint(x: width - arrowHeight + x, y: arrowPosition + arrowWidthHalf))
            bezierPath.addLine(to: CGPoint(x: width - arrowHeight + x, y: height - bottomRightRadius - x))
            bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height + x))
            bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: .pi, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: x, y: arrowHeight + topLeftRadius + x))
            bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: .pi, endAngle: pi_3_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width - topRightRadius + x - arrowHeight, y: x))
            bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
            
        case .none:
            topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: topLeftRadius + x)
            topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y: topRightRadius + x)
            bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x)
            bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x)
            
            bezierPath.move(to: CGPoint(x: topLeftRadius + x, y: x))
            bezierPath.addLine(to: CGPoint(x: width - topRightRadius, y: x))
            bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: 2 * .pi, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x))
            bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height + x))
            bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: .pi, clockwise: true)
            
            bezierPath.addLine(to: CGPoint(x: x, y: arrowHeight + topLeftRadius + x))
            bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: .pi, endAngle: pi_3_2, clockwise: true)
        }
        bezierPath.close()
        backConfig.backColor.setFill()
        backConfig.borderColor.setStroke()
        return bezierPath
    }
}
