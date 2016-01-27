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
    
    var image: UIImage? {
        didSet{
            if image != nil {
                setupImageView(image!)
            }
        }
    }
    
    func setupImageView(image: UIImage) {
        //  这个要重新设置为初始未放大状态，很重要
        scrollView?.zoomScale = 1.0
        
        let imageSize = image.size
        let screenSize = UIScreen.mainScreen().bounds.size
        
        // 2. 按照宽度进行缩放，得到图片按照屏幕比例缩放 到 屏幕宽度后的高度
        let h = screenSize.width / imageSize.width * imageSize.height
        
        let rect = CGRectMake(0, 0, screenSize.width, h)
        imageView!.frame = rect
        imageView!.image = image
        scrollView!.frame = CGRectMake(margin, 0, self.bounds.width - 2 * margin, self.bounds.height)

        scrollView!.contentSize = rect.size

        adjustImageViewFrame()
    }
    
    /// 调节图片在scrollView中的位置
    func adjustImageViewFrame() {
        
        let imageH = imageView!.frame.height
        let scrollH = scrollView!.frame.height
        
        if scrollH < imageH {   // 长图
            imageView?.frame.origin.y = 0;
            
        }else {// 短图,需要垂直居中
            imageView?.frame.origin.y = (scrollH - imageH) * 0.5;
        }
    }
    
    
    var scrollView: UIScrollView?
    var imageView: UIImageView?
    
    override func awakeFromNib() {
        
        scrollView = UIScrollView()
        self.addSubview(scrollView!)
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 1.0
        scrollView!.delegate = self
        
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
    
    /// scrollView和collectionView前后两端的间距，在sb中查看可知collectionView的宽度前后分别超出
    /// 屏幕10个点，而cell的size与collectionView一致，于是scrollView位于cell正中间，前后相差分别为10
    // 不能改变此值，因为约束在sb中间
    private let margin: CGFloat = 10
    
    // MARK: 图片缩放代理方法
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        adjustImageViewFrame()
    }
}