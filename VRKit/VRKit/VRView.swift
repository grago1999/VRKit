//
//  VRView.swift
//  VRKit
//
//  Created by Gianluca Rago on 6/17/16.
//  Copyright © 2016 Gianluca Rago. All rights reserved.
//

import UIKit
import CoreMotion

class VRView: UIView {
    
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    private let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    private var isContinuous:Bool = false
    
    private var leftView:UIView
    private var rightView:UIView
    
    private var motionManager = CMMotionManager()
    
    private var leftSubViews:[UIView]
    private var rightSubViews:[UIView]
    
    private var leftMargin:CGFloat = 0.0
    private var rightMargin:CGFloat = 0.0
    private var topMargin:CGFloat = 0.0
    private var bottomMargin:CGFloat = 0.0
    
    init() {
        leftView = UIView(frame:CGRect(x:0, y:0, width:screenWidth/2, height:screenHeight))
        leftView.layer.masksToBounds = true
        rightView = UIView(frame:CGRect(x:screenWidth/2, y:0, width:screenWidth/2, height:screenHeight))
        rightView.layer.masksToBounds = true
        leftSubViews = []
        rightSubViews = []
        super.init(frame:CGRect(x:0, y:0, width:screenWidth, height:screenHeight))
        self.addSubview(leftView)
        self.addSubview(rightView)
        
        if motionManager.gyroAvailable && !motionManager.gyroActive {
            let interval = 1.0/120.0
            motionManager.deviceMotionUpdateInterval = interval
            motionManager.startDeviceMotionUpdates()
            
            motionManager.gyroUpdateInterval = interval
            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData:CMGyroData?, error:NSError?) in
                for vrSubView in self.getAllSubViews() {
                    vrSubView.frame = CGRectOffset(vrSubView.frame, CGFloat((gyroData?.rotationRate.x)!), CGFloat(-(gyroData?.rotationRate.y)!))
                }
            })
        }
    }
    
    required init?(coder aDecoder:NSCoder) {
        leftView = UIView()
        rightView = UIView()
        leftSubViews = []
        rightSubViews = []
        super.init(coder:aDecoder)
    }
    
    func setContinuous(value:Bool) {
        isContinuous = value
        alterContinuousViews()
    }
    
    private func alterContinuousViews() {
        if isContinuous {
            for subView in leftSubViews {
                if subView.frame.origin.x < leftMargin {
                    leftMargin = subView.frame.origin.x
                }
                if subView.frame.origin.x+subView.frame.size.width > rightMargin {
                    rightMargin = subView.frame.origin.x+subView.frame.size.width
                }
                if subView.frame.origin.y < topMargin {
                    topMargin = subView.frame.origin.y
                }
                if subView.frame.origin.y+subView.frame.size.height > bottomMargin {
                    bottomMargin = subView.frame.origin.y+subView.frame.size.height
                }
            }
        } else {
            leftMargin = 0.0
            rightMargin = 0.0
            topMargin = 0.0
            bottomMargin = 0.0
        }
    }
    
    func addVRSubView(view:UIView) {
        let leftSubView = view
        let rightSubView = view.copyView() as! UIView
        leftView.addSubview(leftSubView)
        rightView.addSubview(rightSubView)
        leftSubViews.append(leftSubView)
        rightSubViews.append(rightSubView)
        alterContinuousViews()
    }
    
    func addVRSubImgView(imgView:UIImageView) {
        let leftSubView = imgView
        let tempImgView = UIImageView(frame:imgView.frame)
        tempImgView.image = imgView.image
        let rightSubView = tempImgView
        leftView.addSubview(leftSubView)
        rightView.addSubview(rightSubView)
        leftSubViews.append(leftSubView)
        rightSubViews.append(rightSubView)
        alterContinuousViews()
    }
    
    private func getAllSubViews() -> [UIView] {
        var allSubViews:[UIView] = []
        for subView in leftSubViews {
            allSubViews.append(subView)
        }
        for subView in rightSubViews {
            allSubViews.append(subView)
        }
        return allSubViews
    }
    
}

extension UIView {
    func copyView() -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}
