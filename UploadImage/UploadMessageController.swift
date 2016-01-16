//
//  UploadMessageController.swift
//  UploadImage
//
//  Created by apple on 16/1/14.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

/// 屏幕比例
let scale = UIScreen.mainScreen().bounds.size.width / 375

class UploadMessageController: UIViewController {

    @IBOutlet weak var uploadImageBtnWConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadImageBtnHConstraint: NSLayoutConstraint!
    
    /// 带占位符的输入框视图
    @IBOutlet weak var inputTextView: PlaceholerTextView!
    
    /// 所有用来上传图片的按钮，为集合视图
    @IBOutlet var uploadImageBtns: [UploadBtn]!
    
    /// 所有已经拍照保存到相应按钮上的图片
    lazy var uploadImages: [UIImage]? = {
        return [UIImage]()
    }()
    
    
    // MARK: - 程序入口
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    
    /// 初始化界面、适配
    func setupUI() {
        
        self.title = "上传资料"
        inputTextView.placeholder = "输入说明..."
        
        uploadImageBtnWConstraint.constant *= scale
        uploadImageBtnHConstraint.constant *= scale
    }
    
    /// 父类默认不做任何事，不必写super.viewWillAppear(animated)
    override func viewWillAppear(animated: Bool) {
        
        for btn in uploadImageBtns {  // 所有按钮状态归零
            btn.hasUploadImage = false
            btn.hidden = true
            btn.setBackgroundImage(UIImage(named: "LBB_Upload切片-2"), forState: .Normal)
        }
        
        for i in 0..<uploadImages!.count {  // 设置图片
            let image = uploadImages![i]
            let btn = uploadImageBtns![i]
            btn.setBackgroundImage(image, forState: .Normal)
            btn.hasUploadImage = true
            btn.hidden = false
        }
        
        if uploadImages?.count < uploadImageBtns.count {    // 让后面那个按钮显示
            uploadImageBtns[uploadImages!.count].hidden = false
        }
    }

    
    /// 上传头像按钮被点击
    @IBAction func uploadimageBtnClicked(btn: UploadBtn) {
        
        if btn.hasUploadImage { // 该按钮已经上传过图片，跳到图片浏览页面
            
            performSegueWithIdentifier("photoBrower", sender: btn.tag)
            return
        }
        
        if !UIImagePickerController.isCameraDeviceAvailable(.Rear) {
            
            showAlertView("请允许访问相机")
            return
        }
        
        /// 拍照
        let picker = UIImagePickerController()
        
        selectBtn = btn
//        objc_setAssociatedObject(picker, associatedUploadBtnKey, btn, .OBJC_ASSOCIATION_RETAIN)
        
        
        picker.delegate = self
        picker.sourceType = .Camera
//        picker.allowsEditing = true   // 设置了也不能编辑图片
        
        // 弹出拍照控制器时出现Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
        // 不知道如何解决？？？？ who know，tell me！！！！
        presentViewController(picker, animated: true, completion: nil)
    }
    
    /// sb控制器跳转segue方法
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationViewController.isKindOfClass(PhotoBrowerController) {
            
            let photoBrower = segue.destinationViewController as! PhotoBrowerController
            
            // OC中，这里控制器PhotoBrowerController和本身控制器数组属性均指向一个数组对象，一改俱改。要的就是这个效果
            // 而swift中不同，看起来也是指向同一个数组，但是不会一改俱改，不知道为嘛？？？
            photoBrower.images = uploadImages
            
            // OC中不必加此闭包回调
            photoBrower.deleteImageClosure = { (index: Int)->() in
                self.uploadImages!.removeAtIndex(index)
            }
        
            photoBrower.currentIndex = sender as! Int
        }
    }
    
    
    /// 被点击的准备上传图片的按钮(本来要用关联属性的，谁知道swift中行不通？？？why)
    private var selectBtn: UploadBtn?
    private let associatedUploadBtnKey = "associatedUploadBtnKey"
    
    
    /// 弹框提示
    func showAlertView(title: String?) {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "确定", style: .Destructive, handler: nil)
        
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        inputTextView.resignFirstResponder()
    }
}


// MARK: - 拍照代理方法
extension UploadMessageController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // let btn = objc_getAssociatedObject(picker, associatedUploadBtnKey) as? UploadBtn
        let btn = selectBtn!
        
        uploadImages!.append(image)
        
        btn.setBackgroundImage(image, forState: .Normal)
        
        btn.hasUploadImage = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /// 压缩图片,上传到服务器时才用
    func compressImage(image: UIImage?, size: CGSize) -> UIImage? {
        
        if image == nil || size.width <= 0.0 || size.height <= 0.0{
            return nil
        }
        
        let data = UIImageJPEGRepresentation(image!, 0.7)
        var newImage = UIImage(data: data!)
        UIGraphicsBeginImageContext(size)
        newImage?.drawInRect(CGRectMake(0, 0, size.width, size.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}


// MARK: - 自定义上传头像按钮

class UploadBtn: UIButton {
    
    // 标记位，表征该按钮有没设置上传的图片
    var hasUploadImage: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
        
        self.adjustsImageWhenHighlighted = false
    }
}


// MARK: - 自定义带站位符的textview

class PlaceholerTextView: UITextView {
    
    var placeholder: NSString? 
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setNeedsDisplay", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    override func drawRect(rect: CGRect) {
        
        if self.hasText() {
            return
        }
        
        let params = [NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(15)]
        
        placeholder?.drawAtPoint(CGPointMake(5, 10), withAttributes: params)
    }
}


