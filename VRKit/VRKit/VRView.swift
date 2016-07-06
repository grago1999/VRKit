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
    
    private var motionManager = CMMotionManager()
    private var netX:CGFloat = 0.0
    private var netY:CGFloat = 0.0
    
    private var isContinuous = false
    private var hasSetMargins = false
    private var hasContinuousViewForView:[UIView:Bool] = [:]
    
    private var leftMargin:CGFloat = 0.0
    private var rightMargin:CGFloat = 0.0
    private var topMargin:CGFloat = 0.0
    private var bottomMargin:CGFloat = 0.0
    
    private var leftView:UIView
    private var rightView:UIView

    private var leftContainerView:UIView
    private var rightContainerView:UIView
    
    private var leftSubViews:[UIView]
    private var rightSubViews:[UIView]
    
    init() {
        leftView = UIView(frame:CGRect(x:0, y:0, width:screenWidth/2, height:screenHeight))
        rightView = UIView(frame:CGRect(x:screenWidth/2, y:0, width:screenWidth/2, height:screenHeight))
        leftContainerView = UIView(frame:CGRect(x:0, y:0, width:screenWidth/2, height:screenHeight))
        leftContainerView.layer.masksToBounds = true
        leftView.addSubview(leftContainerView)
        rightContainerView = UIView(frame:CGRect(x:0, y:0, width:screenWidth/2, height:screenHeight))
        rightContainerView.layer.masksToBounds = true
        rightView.addSubview(rightContainerView)
        hasContinuousViewForView[leftContainerView] = false
        hasContinuousViewForView[rightContainerView] = false
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
                let x:CGFloat = CGFloat((gyroData?.rotationRate.x)!)
                let y:CGFloat = CGFloat((gyroData?.rotationRate.y)!)
                switch UIDevice.currentDevice().orientation {
                case .LandscapeLeft:
                    for vrSubView in self.getAllSubViews() {
                        vrSubView.frame = CGRectOffset(vrSubView.frame, x, -y)
                    }
                    self.netX+=x
                    self.netY+=y
                default:
                    for vrSubView in self.getAllSubViews() {
                        vrSubView.frame = CGRectOffset(vrSubView.frame, -x, y)
                    }
                    self.netX-=x
                    self.netY-=y
                }
                //print("Net X: \(self.netX), Net Y: \(self.netY)")
                self.checkContinuousViews()
            })
        }
    }
    
    required init?(coder aDecoder:NSCoder) {
        leftView = UIView()
        rightView = UIView()
        leftContainerView = UIView()
        rightContainerView = UIView()
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
            hasSetMargins = true
        } else {
            leftMargin = 0.0
            rightMargin = 0.0
            topMargin = 0.0
            bottomMargin = 0.0
            hasSetMargins = false
        }
    }
    
    private func checkContinuousViews() {
        let margin:CGFloat = 20.0
        if isContinuous && hasSetMargins {
            if netX+margin < leftMargin {
                let hasView = hasContinuousViewForView[leftContainerView]
                if !hasView! {
                    addContinuousView(1, margin:margin)
                }
            }
            if netX+(screenWidth/2)+margin > rightMargin {
                let hasView = hasContinuousViewForView[leftContainerView]
                if !hasView! {
                    addContinuousView(0, margin:margin)
                }
            }
            /*if netY+margin < topMargin {
                
            }
            if netY-margin > bottomMargin {
                
            }*/
        }
    }
    
    private func addContinuousView(fromSide:Int, margin:CGFloat) { // 0 is left, 1 is right
        var container1:UIView = UIView()
        var container2:UIView = UIView()
        if fromSide == 0 {
            leftView.layer.zPosition = 2
            container1 = leftContainerView
            container2 = rightContainerView
        } else {
            rightView.layer.zPosition = 2
            container1 = rightContainerView
            container2 = leftContainerView
        }
        let newContainer1:UIView = container1.copyView() as! UIView
        newContainer1.frame = CGRectOffset(container1.frame, -screenWidth/2, 0)
        newContainer1.layer.masksToBounds = false
        if fromSide == 0 {
            leftView.addSubview(newContainer1)
        } else {
            rightView.addSubview(newContainer1)
        }
        for subView in container1.subviews {
            if let imgView = subView as? UIImageView {
                let tempImgView = UIImageView(frame:imgView.frame)
                tempImgView.image = imgView.image
                newContainer1.addSubview(tempImgView)
                if fromSide == 0 {
                    leftSubViews.append(tempImgView)
                } else {
                    rightSubViews.append(tempImgView)
                }
            }
        }
        for subView in newContainer1.subviews {
            subView.frame = CGRectOffset(subView.frame, -screenWidth*(5/8)-(margin*2.25), 0)
        }
        hasContinuousViewForView[container1] = true
        hasContinuousViewForView[newContainer1] = true
        
        let newContainer2:UIView = container2.copyView() as! UIView
        newContainer2.frame = CGRectOffset(container2.frame, -screenWidth/2, 0)
        newContainer2.layer.masksToBounds = false
        if fromSide == 0 {
            rightView.addSubview(newContainer2)
        } else {
            leftView.addSubview(newContainer2)
        }
        for subView in container2.subviews {
            if let imgView = subView as? UIImageView {
                let tempImgView = UIImageView(frame:imgView.frame)
                tempImgView.image = imgView.image
                newContainer2.addSubview(tempImgView)
                if fromSide == 0 {
                    rightSubViews.append(tempImgView)
                } else {
                    leftSubViews.append(tempImgView)
                }
            }
        }
        for subView in newContainer2.subviews {
            subView.frame = CGRectOffset(subView.frame, -screenWidth*(5/8)-(margin*2.25), 0)
        }
        hasContinuousViewForView[container2] = true
        hasContinuousViewForView[newContainer2] = true
    }
    
    func addVRSubView(view:UIView) {
        let leftSubView = view
        let rightSubView = view.copyView() as! UIView
        leftContainerView.addSubview(leftSubView)
        rightContainerView.addSubview(rightSubView)
        leftSubViews.append(leftSubView)
        rightSubViews.append(rightSubView)
        alterContinuousViews()
    }
    
    func addVRSubImgView(imgView:UIImageView) {
        let leftSubView = imgView
        let tempImgView = UIImageView(frame:imgView.frame)
        tempImgView.image = imgView.image
        let rightSubView = tempImgView
        leftContainerView.addSubview(leftSubView)
        rightContainerView.addSubview(rightSubView)
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
