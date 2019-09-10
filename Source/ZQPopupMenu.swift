//
//  ZQPopupMenu.swift
//  ZQPopupMenuDemo
//
//  Created by Darren on 2019/4/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: ZQPopupMenuTableViewCell
fileprivate class ZQPopupMenuTableViewCell: UITableViewCell {
    
    fileprivate lazy var separatorView:UIView = {
        let separatorView:UIView = UIView()
        return separatorView
    }()
    
    fileprivate var index:Int? {
        didSet {
            guard let row = index else {
                textLabel?.text = nil
                textLabel?.attributedText = nil
                imageView?.image = nil
                separatorView.isHidden = true
                return
            }
            let info = ZQPopupMenuConfig.default.itemConfig
            if !info.showSeparator {
                separatorView.isHidden = true
                return
            }
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
            separatorView.frame = CGRect(x: info.separatorSpace, y: info.itemHeight - info.separatorHeight, width: info.itemWidth - 2 * info.separatorSpace, height: info.separatorHeight)
            separatorView.backgroundColor = info.separatorColor
            separatorView.isHidden = row == info.titlesArr.count - 1
        }
    }
    
//    fileprivate var itemConfig:ZQPopupMenuItemConfig? {
//        didSet {
//            if let info = itemConfig {
//                if !info.showSeparator {
//                    separatorView.isHidden = true
//                    return
//                }
//                if let row = index {
//                    if info.titlesArr[row].isKind(of: NSAttributedString.self) {
//                        textLabel?.attributedText = (info.titlesArr[row] as! NSAttributedString)
//                    }
//                    else if info.titlesArr[row].isKind(of: NSString.self) {
//                        textLabel?.textColor = info.textColor
//                        textLabel?.font = info.font
//                        textLabel?.text = info.titlesArr[row] as! NSString as String
//                    }
//                    else {
//                        textLabel?.text = nil
//                        textLabel?.attributedText = nil
//                    }
//
//                    if info.imagesArr.count >= row + 1 {
//                        if info.imagesArr[row].isKind(of: NSString.self) {
//                            imageView?.image = UIImage(named: info.imagesArr[row] as! NSString as String)
//                        }
//                        else if info.imagesArr[row].isKind(of: UIImage.self) {
//                            imageView?.image = (info.imagesArr[row] as! UIImage)
//                        }
//                        else {
//                            imageView?.image = nil
//                        }
//                    }
//                    else {
//                        imageView?.image = nil
//                    }
//                    separatorView.frame = CGRect(x: info.separatorSpace, y: info.itemHeight - info.separatorHeight, width: info.itemWidth - 2 * info.separatorSpace, height: info.separatorHeight)
//                    separatorView.backgroundColor = info.separatorColor
//                    separatorView.isHidden = row == info.titlesArr.count - 1
//                }
//                else {
//                    textLabel?.text = nil
//                    textLabel?.attributedText = nil
//                    imageView?.image = nil
//                    separatorView.isHidden = true
//                }
//            }
//        }
//    }
    
    // MARK: life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: private
extension ZQPopupMenuTableViewCell {
    fileprivate func setupViews() {
        selectionStyle = .none
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
    
    /// 自定义cell的Class
    ///
    /// - Parameter popMenu: 弹窗视图
    /// - Returns: AnyClass
    @objc optional func customTableViewCellClassForPopMenu(popMenu:ZQPopupMenu) -> AnyClass
    
    /// 自定义cell的Nib
    ///
    /// - Parameter popMenu: 弹窗视图
    /// - Returns: UINib
    @objc optional func customTableViewCellNibForPopMenu(popMenu:ZQPopupMenu) -> UINib
    
    /// 自定义cell的个数
    ///
    /// - Parameter popMenu: 弹窗视图
    /// - Returns: Int
    @objc optional func customTableViewCellNumber(popMenu:ZQPopupMenu) -> Int
    
    /// 自定义cell的数据填充
    ///
    /// - Parameters:
    ///   - popMenu: 弹窗视图
    ///   - cell: 自定义cell
    ///   - index: 索引
    @objc optional func setupCustomTableViewCell(popMenu:ZQPopupMenu, cell:UITableViewCell, forIndex index:Int)
}

// MARK: 弹窗菜单视图
public class ZQPopupMenu: UIView {
    
    fileprivate let reuseIdentifier:String = "ZQPopupMenuTableViewCell"
    
    /// 配置信息
    fileprivate var config:ZQPopupMenuConfig = ZQPopupMenuConfig.default
    
    /// 背景设置
    fileprivate var backConfig:ZQPopupMenuBackConfig = ZQPopupMenuConfig.default.backConfig
    
    /// 箭头设置
    fileprivate var arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuConfig.default.arrowConfig
    
    /// item设置
    fileprivate var itemConfig:ZQPopupMenuItemConfig = ZQPopupMenuConfig.default.itemConfig
    
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
        backView.backgroundColor = backConfig.maskColor
        backView.alpha = 0
        backView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionForBackView))
        backView.addGestureRecognizer(tap)
        return backView
    }()
    
    fileprivate lazy var tableView:UITableView = {
        let tableView:UITableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = itemConfig.itemHeight
        tableView.showsVerticalScrollIndicator = backConfig.showsVerticalScrollIndicator
        tableView.showsHorizontalScrollIndicator = backConfig.showsHorizontalScrollIndicator
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate weak var delegate:ZQPopupMenuDelegate?
    
    // MARK: life cycle
    public init(delegate:ZQPopupMenuDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        setupViews()
        registCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("--__--|| \(self.classForCoder) dealloc")
    }
    
    public override var frame: CGRect {
        didSet {
            let borderWidth:CGFloat = backConfig.borderWidth
            let arrowHeight:CGFloat = arrowConfig.arrowHeight
            switch arrowConfig.arrowDirection {
            case .top:
                self.tableView.frame = CGRect(x: borderWidth, y: borderWidth + arrowHeight, width: frame.size.width - borderWidth * 2, height: frame.size.height - arrowHeight)
                
            case .bottom:
                self.tableView.frame = CGRect(x: borderWidth, y: borderWidth, width: frame.size.width - borderWidth * 2, height: frame.size.height - arrowHeight)
                
            case .left:
                self.tableView.frame = CGRect(x: borderWidth + arrowHeight, y: borderWidth, width: frame.size.width - borderWidth * 2 - arrowHeight, height: frame.size.height)
                
            case .right:
                self.tableView.frame = CGRect(x: borderWidth, y: borderWidth, width: frame.size.width - borderWidth * 2 - arrowHeight, height: frame.size.height)
                
            case .none:break
            }
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let bezierPath:UIBezierPath = UIBezierPath.creat(rect)
        bezierPath.fill()
        bezierPath.stroke()
    }
}

// MARK: public
public extension ZQPopupMenu {
    
    @discardableResult
    class func showMenu(delegate:ZQPopupMenuDelegate?) -> ZQPopupMenu {
        let popMenu = ZQPopupMenu(delegate: delegate)
        popMenu.show()
        return popMenu
    }
    
    func show() {
        delegate?.willShow?(popMenu: self)
        updateUI()
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
    
    func dismiss() {
        delegate?.willDismiss?(popMenu: self)
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
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        if backConfig.showMaskView {
            window.addSubview(backView)
        }
        alpha = 0
        window.addSubview(self)
        addSubview(tableView)
    }
    
    fileprivate func registCell() {
        if let cellClass = delegate?.customTableViewCellClassForPopMenu?(popMenu: self) {
            tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
        }
        else if let cellNib = delegate?.customTableViewCellNibForPopMenu?(popMenu: self) {
            tableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
        }
        else {
            tableView.register(ZQPopupMenuTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    fileprivate func updateUI() {
        
        /// 必须设置成UIColor.clear,不然重写的draw(_ rect: CGRect)方法里无效
        backgroundColor = UIColor.clear
        if backConfig.showShadow {
            layer.shadowOpacity = Float(backConfig.shadowOpacity)
            layer.shadowOffset = backConfig.shadowOffset
            layer.shadowRadius = backConfig.shadowRadius
        }
        updateArrow()
        updateFrame()
        tableView.reloadData()
        setNeedsDisplay()
    }
    
    fileprivate func updateArrow() {
        if let _ = delegate?.customTableViewCellClassForPopMenu?(popMenu: self), let customCellNumber = delegate?.customTableViewCellNumber?(popMenu: self) {
            cellCount =  customCellNumber
        }
        else if let _ = delegate?.customTableViewCellNibForPopMenu?(popMenu: self), let customCellNumber = delegate?.customTableViewCellNumber?(popMenu: self) {
            cellCount =  customCellNumber
        }
        else {
            cellCount = itemConfig.titlesArr.count
        }
        
        /// 计算内容总高度
        if cellCount > itemConfig.maxVisibleCount {
            contentHeight = itemConfig.itemHeight * CGFloat(itemConfig.maxVisibleCount) + backConfig.borderWidth * 2
            tableView.bounces = true
        }
        else {
            contentHeight = itemConfig.itemHeight * CGFloat(cellCount) + backConfig.borderWidth * 2
            tableView.bounces = false
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
}

// MARK: action
extension ZQPopupMenu {
    @objc func actionForBackView() {
        if backConfig.dismissOnTouchBack {
            dismiss()
        }
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension ZQPopupMenu:UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let _ = delegate?.customTableViewCellClassForPopMenu?(popMenu: self), let _ = delegate?.setupCustomTableViewCell?(popMenu: self, cell: cell, forIndex: indexPath.item) {
            delegate?.setupCustomTableViewCell?(popMenu: self, cell: cell, forIndex: indexPath.item)
            return cell
        } else if let _ = delegate?.customTableViewCellNibForPopMenu?(popMenu: self), let _ = delegate?.setupCustomTableViewCell?(popMenu: self, cell: cell, forIndex: indexPath.item) {
            delegate?.setupCustomTableViewCell?(popMenu: self, cell: cell, forIndex: indexPath.item)
            return cell
        }
        else {
            if cell.isKind(of: ZQPopupMenuTableViewCell.self) {
                (cell as! ZQPopupMenuTableViewCell).index = indexPath.row
            }
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelected?(popMenu: self, index: indexPath.row)
        if backConfig.dismissOnSelected {
            dismiss()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemConfig.itemHeight
    }
}

// MARK: UIBezierPath + Extension
public extension UIBezierPath {
    fileprivate class func drawArrowDirectionTop(bezierPath:UIBezierPath, topLeftRadius:CGFloat, topRightRadius:CGFloat, bottomLeftRadius:CGFloat, bottomRightRadius:CGFloat, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        let arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuConfig.default.arrowConfig
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let arrowWidthHalf:CGFloat = arrowConfig.arrowWidth / 2
        var arrowPosition:CGFloat = arrowConfig.arrowPosition
        
        let topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: arrowHeight + topLeftRadius + x)
        let topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y: arrowHeight + topRightRadius + x)
        let bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x)
        let bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x)
        
        if arrowPosition < topLeftRadius + arrowWidthHalf {
            arrowPosition = topLeftRadius + arrowWidthHalf
        }
        else if arrowPosition > width - topRightRadius - arrowWidthHalf {
            arrowPosition = width - topRightRadius - arrowWidthHalf
        }
        
        let pi:CGFloat = .pi
        let pi_3_2:CGFloat = .pi * 3 / 2
        let pi_1_2:CGFloat = .pi / 2
        let pi_2:CGFloat = .pi * 2
        
        bezierPath.move(to: CGPoint(x: arrowPosition - arrowWidthHalf, y: arrowHeight + x))
        bezierPath.addLine(to: CGPoint(x: arrowPosition, y: y + x))
        bezierPath.addLine(to: CGPoint(x: arrowPosition + arrowWidthHalf, y: arrowHeight + x))
        bezierPath.addLine(to: CGPoint(x: width - topRightRadius, y: arrowHeight + x))
        bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x))
        bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height + x))
        bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: pi, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: x, y: arrowHeight + topLeftRadius + x))
        bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: pi, endAngle: pi_3_2, clockwise: true)
    }
    
    fileprivate class func drawArrowDirectionBottom(bezierPath:UIBezierPath, topLeftRadius:CGFloat, topRightRadius:CGFloat, bottomLeftRadius:CGFloat, bottomRightRadius:CGFloat, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        let arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuConfig.default.arrowConfig
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let arrowWidthHalf:CGFloat = arrowConfig.arrowWidth / 2
        var arrowPosition:CGFloat = arrowConfig.arrowPosition
        
        let topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: topLeftRadius + x)
        let topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y: topRightRadius + x)
        let bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x - arrowHeight)
        let bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x - arrowHeight)
        
        if arrowPosition < bottomLeftRadius + arrowWidthHalf {
            arrowPosition = bottomLeftRadius + arrowWidthHalf
        }
        else if arrowPosition > width - bottomRightRadius - arrowWidthHalf {
            arrowPosition = width - bottomRightRadius - arrowWidthHalf
        }
        
        let pi:CGFloat = .pi
        let pi_3_2:CGFloat = .pi * 3 / 2
        let pi_1_2:CGFloat = .pi / 2
        let pi_2:CGFloat = .pi * 2
        
        bezierPath.move(to: CGPoint(x: arrowPosition + arrowWidthHalf, y: height - arrowHeight + x))
        bezierPath.addLine(to: CGPoint(x: arrowPosition, y: height + x))
        bezierPath.addLine(to: CGPoint(x: arrowPosition - arrowWidthHalf, y: height - arrowHeight + x))
        bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height - arrowHeight + x))
        bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: pi, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: x, y: topLeftRadius + x))
        bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: pi, endAngle: pi_3_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width - topRightRadius + x, y: x))
        bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x - arrowHeight))
        bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
    }
    
    fileprivate class func drawArrowDirectionLeft(bezierPath:UIBezierPath, topLeftRadius:CGFloat, topRightRadius:CGFloat, bottomLeftRadius:CGFloat, bottomRightRadius:CGFloat, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        let arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuConfig.default.arrowConfig
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let arrowWidthHalf:CGFloat = arrowConfig.arrowWidth / 2
        var arrowPosition:CGFloat = arrowConfig.arrowPosition
        
        let topLeftArcCenter = CGPoint(x: topLeftRadius + x + arrowHeight,
                                       y:  topLeftRadius + x)
        let topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y:  topRightRadius + x)
        let bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x + arrowHeight,
                                          y: height - bottomLeftRadius + x)
        let bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x)
        
        if arrowPosition < topLeftRadius + arrowWidthHalf {
            arrowPosition = topLeftRadius + arrowWidthHalf
        }
        else if arrowPosition > height - bottomLeftRadius - arrowWidthHalf {
            arrowPosition = height - bottomLeftRadius - arrowWidthHalf
        }
        
        let pi:CGFloat = .pi
        let pi_3_2:CGFloat = .pi * 3 / 2
        let pi_1_2:CGFloat = .pi / 2
        let pi_2:CGFloat = .pi * 2
        
        bezierPath.move(to: CGPoint(x: arrowHeight + x, y: arrowPosition + arrowWidthHalf))
        bezierPath.addLine(to: CGPoint(x: x, y: arrowPosition))
        bezierPath.addLine(to: CGPoint(x: arrowHeight + x, y: arrowPosition - arrowWidthHalf))
        bezierPath.addLine(to: CGPoint(x: arrowHeight + x, y: topLeftRadius + x))
        bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: pi, endAngle: pi_3_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width - topRightRadius, y: x))
        bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x))
        bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: arrowHeight + bottomLeftRadius + x, y: height + x))
        bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: pi, clockwise: true)
    }
    
    fileprivate class func drawArrowDirectionRight(bezierPath:UIBezierPath, topLeftRadius:CGFloat, topRightRadius:CGFloat, bottomLeftRadius:CGFloat, bottomRightRadius:CGFloat, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        let arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuConfig.default.arrowConfig
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        let arrowWidthHalf:CGFloat = arrowConfig.arrowWidth / 2
        var arrowPosition:CGFloat = arrowConfig.arrowPosition
        
        let topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: topLeftRadius + x)
        let topRightArcCenter = CGPoint(x: width - topRightRadius + x - arrowHeight,
                                        y:  topRightRadius + x)
        let bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x)
        let bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x - arrowHeight,
                                           y: height - bottomRightRadius + x)
        
        if arrowPosition < topRightRadius + arrowWidthHalf {
            arrowPosition = topRightRadius + arrowWidthHalf
        }
        else if arrowPosition > height - bottomRightRadius - arrowWidthHalf {
            arrowPosition = height - bottomRightRadius - arrowWidthHalf
        }
        
        let pi:CGFloat = .pi
        let pi_3_2:CGFloat = .pi * 3 / 2
        let pi_1_2:CGFloat = .pi / 2
        let pi_2:CGFloat = .pi * 2
        
        bezierPath.move(to: CGPoint(x: width - arrowHeight + x, y: arrowPosition - arrowWidthHalf))
        bezierPath.addLine(to: CGPoint(x: width + x, y: arrowPosition))
        bezierPath.addLine(to: CGPoint(x: width - arrowHeight + x, y: arrowPosition + arrowWidthHalf))
        bezierPath.addLine(to: CGPoint(x: width - arrowHeight + x, y: height - bottomRightRadius - x))
        bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height + x))
        bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: pi, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: x, y: arrowHeight + topLeftRadius + x))
        bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: pi, endAngle: pi_3_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width - topRightRadius + x - arrowHeight, y: x))
        bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
    }
    
    fileprivate class func drawArrowDirectionNone(bezierPath:UIBezierPath, topLeftRadius:CGFloat, topRightRadius:CGFloat, bottomLeftRadius:CGFloat, bottomRightRadius:CGFloat, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        let arrowConfig:ZQPopupMenuArrowConfig = ZQPopupMenuConfig.default.arrowConfig
        let arrowHeight:CGFloat = arrowConfig.arrowHeight
        
        let topLeftArcCenter = CGPoint(x: topLeftRadius + x,
                                       y: topLeftRadius + x)
        let topRightArcCenter = CGPoint(x: width - topRightRadius + x,
                                        y: topRightRadius + x)
        let bottomLeftArcCenter = CGPoint(x: bottomLeftRadius + x,
                                          y: height - bottomLeftRadius + x)
        let bottomRightArcCenter = CGPoint(x: width - bottomRightRadius + x,
                                           y: height - bottomRightRadius + x)
        
        let pi:CGFloat = .pi
        let pi_3_2:CGFloat = .pi * 3 / 2
        let pi_1_2:CGFloat = .pi / 2
        let pi_2:CGFloat = .pi * 2
        
        bezierPath.move(to: CGPoint(x: topLeftRadius + x, y: x))
        bezierPath.addLine(to: CGPoint(x: width - topRightRadius, y: x))
        bezierPath.addArc(withCenter: topRightArcCenter, radius: topRightRadius, startAngle: pi_3_2, endAngle: pi_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: width + x, y: height - bottomRightRadius - x))
        bezierPath.addArc(withCenter: bottomRightArcCenter, radius: bottomRightRadius, startAngle: 0, endAngle: pi_1_2, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: bottomLeftRadius + x, y: height + x))
        bezierPath.addArc(withCenter: bottomLeftArcCenter, radius: bottomLeftRadius, startAngle: pi_1_2, endAngle: pi, clockwise: true)
        
        bezierPath.addLine(to: CGPoint(x: x, y: arrowHeight + topLeftRadius + x))
        bezierPath.addArc(withCenter: topLeftArcCenter, radius: topLeftRadius, startAngle: pi, endAngle: pi_3_2, clockwise: true)
    }
    
    fileprivate class func creat(_ rect:CGRect) -> UIBezierPath {
        let bezierPath:UIBezierPath = UIBezierPath()
        let config:ZQPopupMenuConfig = ZQPopupMenuConfig.default
        let backConfig:ZQPopupMenuBackConfig = config.backConfig
        let borderWidth:CGFloat = backConfig.borderWidth
        let rectCorner:UIRectCorner = backConfig.rectCorner
        let cornerRadius:CGFloat = backConfig.cornerRadius
        
        let arrowConfig:ZQPopupMenuArrowConfig = config.arrowConfig
        let arrowDirection:ZQPopupMenuArrowDirection = arrowConfig.arrowDirection
        
        bezierPath.lineWidth = borderWidth
        
        let x:CGFloat = borderWidth / 2
        let y:CGFloat = borderWidth / 2
        let width:CGFloat = rect.size.width - borderWidth
        let height:CGFloat = rect.size.height - borderWidth
        
        var topRightRadius:CGFloat = 0,
        topLeftRadius:CGFloat = 0,
        bottomRightRadius:CGFloat = 0,
        bottomLeftRadius:CGFloat = 0
        
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
        
        switch arrowDirection {
        case .top:
            drawArrowDirectionTop(bezierPath: bezierPath, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, x: x, y: y, width: width, height: height)
            
        case .bottom:
            drawArrowDirectionBottom(bezierPath: bezierPath, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, x: x, y: y, width: width, height: height)
            
        case .left:
            drawArrowDirectionLeft(bezierPath: bezierPath, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, x: x, y: y, width: width, height: height)
            
        case .right:
            drawArrowDirectionRight(bezierPath: bezierPath, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, x: x, y: y, width: width, height: height)
            
        case .none:
            drawArrowDirectionNone(bezierPath: bezierPath, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius, x: x, y: y, width: width, height: height)
        }
        bezierPath.close()
        backConfig.backColor.setFill()
        backConfig.borderColor.setStroke()
        return bezierPath
    }
}
