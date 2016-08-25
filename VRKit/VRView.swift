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
    private var isCalibrated = false
    
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
        leftSubViews = []
        rightSubViews = []
        super.init(frame:CGRect(x:0, y:0, width:screenWidth, height:screenHeight))
        self.addSubview(leftView)
        self.addSubview(rightView)
        
        let motionRate:CGFloat = 4.0
        if motionManager.gyroAvailable && !motionManager.gyroActive {
            let interval = 1.0/120.0
            motionManager.startDeviceMotionUpdates()
            motionManager.deviceMotionUpdateInterval = interval
            motionManager.gyroUpdateInterval = interval
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { deviceManager, error in
                // Based on http://stackoverflow.com/questions/9478630/get-pitch-yaw-roll-from-a-cmrotationmatrix/18764368#18764368
                if !self.isCalibrated {
                    let quaternion = deviceManager?.attitude.quaternion
                    let roll = self.radiansToDegrees(atan2(2*(quaternion!.y*quaternion!.w - quaternion!.x*quaternion!.z), 1 - 2*quaternion!.y*quaternion!.y - 2*quaternion!.z*quaternion!.z))
                    let pitch = self.radiansToDegrees(atan2(2*(quaternion!.x*quaternion!.w + quaternion!.y*quaternion!.z), 1 - 2*quaternion!.x*quaternion!.x - 2*quaternion!.z*quaternion!.z))
                    let yaw = self.radiansToDegrees(asin(2*quaternion!.x*quaternion!.y + 2*quaternion!.w*quaternion!.z))
                }
            })
            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData:CMGyroData?, error:NSError?) in
                let x:CGFloat = CGFloat((gyroData?.rotationRate.x)!)*motionRate
                let y:CGFloat = CGFloat((gyroData?.rotationRate.y)!)*motionRate
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
            print(leftMargin)
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
            if netX-margin < leftMargin {
                addContinuousView(1, margin:margin)
            }
            if netX+(screenWidth/2)+margin > rightMargin {
                addContinuousView(0, margin:margin)
            }
            /*if netY+margin < topMargin {
             
             }
             if netY-margin > bottomMargin {
             
             }*/
        }
    }
    
    private func addContinuousView(fromSide:Int, margin:CGFloat) { // 0 is left, 1 is right
        hasSetMargins = false
        var sideView1:UIView = UIView()
        var sideView2:UIView = UIView()
        var container1:UIView = UIView()
        var container2:UIView = UIView()
        if fromSide == 0 {
            leftView.layer.zPosition = 2
            container1 = leftContainerView
            container2 = rightContainerView
            sideView1 = leftView
            sideView2 = rightView
        } else {
            rightView.layer.zPosition = 2
            container1 = rightContainerView
            container2 = leftContainerView
            sideView1 = rightView
            sideView2 = leftView
        }
        createContainer(&container1, sideView:sideView1, fromSide:fromSide)
        createContainer(&container2, sideView:sideView2, fromSide:fromSide)
        alterContinuousViews()
    }
    
    private func createContainer(inout container:UIView, sideView:UIView, fromSide:Int) {
        let newContainer:UIView = container.copyView() as! UIView
        var xOffset:CGFloat = abs(leftMargin-rightMargin)
        if fromSide == 0 {
            xOffset = -abs(leftMargin-rightMargin)
        }
        newContainer.frame = CGRectOffset(container.frame, xOffset, 0)
        newContainer.layer.masksToBounds = false
        sideView.addSubview(newContainer)
        for subView in container.subviews {
            if let imgView = subView as? UIImageView {
                let tempImgView = UIImageView(frame:imgView.frame)
                tempImgView.image = imgView.image
                newContainer.addSubview(tempImgView)
                if fromSide == 0 {
                    leftSubViews.append(tempImgView)
                } else {
                    rightSubViews.append(tempImgView)
                }
            }
        }
        container = newContainer
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
    
    private func radiansToDegrees(val:Double) -> Double {
        return val*(180/M_PI)
    }
    
}

extension UIView {
    func copyView() -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}