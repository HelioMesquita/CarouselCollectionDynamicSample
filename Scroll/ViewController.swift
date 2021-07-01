//
//  ViewController.swift
//  Scroll
//
//  Created by Hélio Mesquita on 15/06/21.
//

import UIKit

class ViewController: UIViewController {
    
    let view2 = CarouselView()
    let sliderSpacing = UISlider(frame: .zero)
    let sliderWidth = UISlider(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.view.addSubview(self.view2)
            self.view2.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.view2.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                self.view2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.view2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.view2.heightAnchor.constraint(equalToConstant: 120)
            ])
            
            self.sliderSpacing.translatesAutoresizingMaskIntoConstraints = false
            self.sliderSpacing.minimumValue = 0
            self.sliderSpacing.maximumValue = 100
            self.view.addSubview(self.sliderSpacing)
            
            NSLayoutConstraint.activate([
                self.sliderSpacing.topAnchor.constraint(equalTo: self.view2.bottomAnchor),
                self.sliderSpacing.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.sliderSpacing.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.sliderSpacing.heightAnchor.constraint(equalToConstant: 120)
            ])
            
            self.sliderSpacing.addTarget(self, action: #selector(self.sliderSpacingValueChanged), for: .allEvents)
            
            
            
            self.sliderWidth.translatesAutoresizingMaskIntoConstraints = false
            self.sliderWidth.minimumValue = 0
            self.sliderWidth.maximumValue = 1
            self.view.addSubview(self.sliderWidth)
            
            NSLayoutConstraint.activate([
                self.sliderWidth.topAnchor.constraint(equalTo: self.sliderSpacing.bottomAnchor),
                self.sliderWidth.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.sliderWidth.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.sliderWidth.heightAnchor.constraint(equalToConstant: 120)
            ])
            
            self.sliderWidth.addTarget(self, action: #selector(self.sliderWidthValueChanged), for: .allEvents)
        }
    }
    
    @objc func sliderSpacingValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        view2.itemSpacing = CGFloat(currentValue)
    }
    
    
    @objc func sliderWidthValueChanged(_ sender: UISlider) {
        view2.itemWidth = CGFloat(sender.value)
    }

}


class CarouselView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var elements = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q",]
    
    var itemSpacing: CGFloat = 10 {
        didSet {
            flowLayout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: itemSpacing)
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    var itemWidth: CGFloat = 0.8 {
        didSet {
            flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width * itemWidth, height: 40)
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    lazy public var flowLayout: UPCarouselFlowLayout = {
        let flow = UPCarouselFlowLayout()
        flow.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: itemSpacing)
        flow.sideItemAlpha = 1
        flow.sideItemScale = 1
        flow.sideItemShift = 0
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 40)
        flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return flow
    }()
    
    lazy public var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(CarouselViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy public var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = elements.count
        pageControl.currentPageIndicatorTintColor = .red
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        self.addSubview(pageControl)
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselViewCell
        cell.backgroundColor = .red
        
        return cell
    }
    
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }
        return currentPage
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }

}

class CarouselViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

import UIKit


public enum UPCarouselFlowLayoutSpacingMode: Equatable {
    case fixed(spacing: CGFloat)
    case overlap(visibleOffset: CGFloat)
}


open class UPCarouselFlowLayout: UICollectionViewFlowLayout {
    
    fileprivate struct LayoutState {
        var size: CGSize
        var direction: UICollectionView.ScrollDirection
        var spacingMode: UPCarouselFlowLayoutSpacingMode
        func isEqual(_ otherState: LayoutState) -> Bool {
            return self.size.equalTo(otherState.size) && self.direction == otherState.direction && self.spacingMode == otherState.spacingMode
        }
    }
    
    @IBInspectable open var sideItemScale: CGFloat = 0.6
    @IBInspectable open var sideItemAlpha: CGFloat = 0.6
    @IBInspectable open var sideItemShift: CGFloat = 0.0
    open var spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 40)
    
    fileprivate lazy var state = LayoutState(size: CGSize.zero, direction: .horizontal, spacingMode: spacingMode)
    
    
    override open func prepare() {
        super.prepare()
        let currentState = LayoutState(size: itemSize, direction: self.scrollDirection, spacingMode: spacingMode)
        
        if !self.state.isEqual(currentState) {
            self.setupCollectionView()
            self.updateLayout()
            self.state = currentState
        }
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView = self.collectionView else { return }
        if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }
    
    fileprivate func updateLayout() {
        guard let collectionView = self.collectionView else { return }
        
        let collectionSize = collectionView.bounds.size
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let side = isHorizontal ? self.itemSize.width : self.itemSize.height
        let scaledItemOffset =  (side - side*self.sideItemScale) / 2
        switch self.spacingMode {
        case .fixed(let spacing):
            self.minimumLineSpacing = spacing - scaledItemOffset
        case .overlap(let visibleOffset):
            let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
            let inset = isHorizontal ? xInset : yInset
            self.minimumLineSpacing = inset - fullSizeSideItemOverlap
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
            let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
            else { return nil }
        return attributes.map({ self.transformLayoutAttributes($0) })
    }
    
    fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let collectionCenter = isHorizontal ? collectionView.frame.size.width/2 : collectionView.frame.size.height/2
        let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
        
        let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance
        
        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        let shift = (1 - ratio) * self.sideItemShift
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 10)
        
        if isHorizontal {
            attributes.center.y = attributes.center.y + shift
        } else {
            attributes.center.x = attributes.center.x + shift
        }
        
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView , !collectionView.isPagingEnabled,
            let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
            else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        
        let isHorizontal = (self.scrollDirection == .horizontal)
        
        let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
        let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
        
        var targetContentOffset: CGPoint
        if isHorizontal {
            let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
        }
        else {
            let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
        }
        
        return targetContentOffset
    }
}
