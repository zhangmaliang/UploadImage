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

// MARK: -UICollectionView数据源方法
extension PhotoBrowerController: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoBrowerCell
        
        cell.image = images![indexPath.item]
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let kCollectionViewW = collectionView.frame.size.width;
        let index = Int(collectionView.contentOffset.x / kCollectionViewW)
        setupTitle(index)
    }
}


// MARK: -照片浏览器自定义cell
class PhotoBrowerCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet{
            imageView.image = image
        }
    }
}