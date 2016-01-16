//
//  PhotoBrowerController.swift
//  UploadImage
//
//  Created by apple on 16/1/14.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class PhotoBrowerController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    var currentIndex: Int = 0
    var images: [UIImage]?
    
    /// 删除图片回调闭包
    var deleteImageClosure: ((index: Int)->())?
    
    // MARK: - 程序入口方法
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCollectionView()
        
        setupTitle(currentIndex)
    }

    
    func setupCollectionView() {
        
        // 惨惨惨，OC不用加，swift必须加，否则cell上面留一段空白，找了哥好久原因
        self.automaticallyAdjustsScrollViewInsets = false
        
        layout.itemSize = collectionView.bounds.size
        
        collectionView.contentOffset = CGPointMake(CGFloat(currentIndex) * collectionView.frame.size.width, 0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "LBB_Upload删除图标"), style: .Done, target: self, action: "deleteImage")
    }
    
    /// 点击右上角删除图片按钮
    func deleteImage() {
        
        if images?.count < 1 {
            return
        }
        
        let kCollectionViewW = collectionView.frame.size.width;

        var index = Int(collectionView.contentOffset.x / kCollectionViewW)

        images?.removeAtIndex(index)
        
        // 删除指定图片回调
        if deleteImageClosure != nil {
            deleteImageClosure!(index: index)
        }
        
        collectionView.reloadData()

        index = Int(collectionView.contentOffset.x / kCollectionViewW)
        
        setupTitle(index)
    }
    
    /// 设置控制器标题
    func setupTitle(index: Int) {
        
        var titleIndex = index
        if images?.count > 0 {
            titleIndex++
        }
        
        if images != nil {
            self.title = "\(titleIndex)/\(images!.count)"
        }
    }
}

// MARK: - UICollectionView数据源、UIScrollView代理方法
extension PhotoBrowerController: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoBrowerCell
        
        cell.image = images![indexPath.item]
        
        // 点击cell上的图片回调
        cell.clickedImageClosure = { ()->() in
            
            self.navgationBarShowAndHiddenAnimation()
        }
        
        return cell
    }
    
    // cell刚刚淡出屏幕时调用(清空刚刚那张被放大了的图片的比例、位置等)
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let photoCell = cell as! PhotoBrowerCell
        
        // 删除图片reloadData时会调用该方法，此时数组元素可能比indexPath.item小，需要过滤
        if images?.count > indexPath.item {
            photoCell.image = images![indexPath.item]
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

        let kCollectionViewW = collectionView.frame.size.width;
        
        let index = Int(collectionView.contentOffset.x / kCollectionViewW)
        
        setupTitle(index)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // 拖拽时，只有导航栏是出现状况才需要动画将其隐藏
        if self.navigationController?.navigationBar.frame.origin.y > 0 {
            navgationBarShowAndHiddenAnimation()
        }
    }
    
    /// 导航栏 出现 & 隐藏 动画
    func navgationBarShowAndHiddenAnimation() {
        
        let offsetY = self.navigationController?.navigationBar.frame.origin.y < 0 ? 20 : -44

        UIView.animateWithDuration(0.25) {
            self.navigationController?.navigationBar.frame.origin.y = CGFloat(offsetY)
        }
    }
}


// MARK: - 照片浏览器自定义cell
class PhotoBrowerCell: UICollectionViewCell,UIScrollViewDelegate {
    
    /// 点击了图片闭包
    var clickedImageClosure: (()->())?
    
    var scrollView: UIScrollView?
    
    var imageView: UIImageView?
    
    var isShortImage: Bool = false   // 短图还是长图
    
    var image: UIImage? {
        didSet{
            if image != nil {
                setupImageView(image!)
            }
        }
    }
    
    /// scrollView和collectionView前后两端的间距，在sb中查看可知collectionView的宽度前后分别超出
    /// 屏幕10个点，而cell的size与collectionView一致，于是scrollView位于cell正中间，前后相差分别为10
    private let margin: CGFloat = 10
    
    func setupImageView(image: UIImage) {
        
        // 0. 将 scrollView 的滚动参数重置
//        scrollView?.contentOffset = CGPointZero
        scrollView?.contentSize = CGSizeZero
//        scrollView?.contentInset = UIEdgeInsetsZero
        
        // 1. 准备参数
        let imageSize = image.size
        let scrollViewSize = CGRectMake(margin, 0, self.bounds.width - 2 * margin, self.bounds.height)
        
        // 2. 按照宽度进行缩放，目标宽度 screenSize.width
        let h = scrollViewSize.width / imageSize.width * imageSize.height
        
        // 直接设置看结果
        let rect = CGRectMake(0, 0, scrollViewSize.width, h)
        imageView!.frame = rect
        imageView!.image = image
        
        // 区分长图和短图
        if rect.size.height > scrollViewSize.height {
            // 设置滚动区域
            scrollView!.contentSize = rect.size
            
        } else {
            isShortImage = true
            
            // 需要垂直居中，设置 inset
            let y = (scrollViewSize.height - h) * 0.5
            scrollView?.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    
    
    override func awakeFromNib() {
        
        scrollView = UIScrollView()
        self.addSubview(scrollView!)
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 1.0
        scrollView!.delegate = self
        
        // 图像视图，大小取决于传递的图像
        imageView = UIImageView()
        scrollView!.addSubview(imageView!)
        
        let gesture = UITapGestureRecognizer(target: self, action: "clickedImage")
        self.addGestureRecognizer(gesture)
    }
    
    /// 点击了图片，回调控制器出现\隐藏导航栏
    func clickedImage() {
        
        if clickedImageClosure != nil {
            clickedImageClosure!()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView!.frame = CGRectMake(margin, 0, self.bounds.width - 2 * margin, self.bounds.height)
    }
  
    
    // MARK: 图片缩放代理方法
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {

        if isShortImage == false {
            return
        }
        
        let y = (frame.size.height - imageView!.frame.size.height) * 0.5
        scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        
        print(imageView?.frame)
        print(imageView?.bounds)
    }
}