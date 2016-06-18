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
    
    private var leftView:UIView
    private var rightView:UIView
    
    private var motionManager = CMMotionManager()
    
    private var leftSubViews:[UIView]
    private var rightSubViews:[UIView]
    
    init() {
        leftView = UIView(frame:CGRect(x:0, y:0, width:screenWidth/2, height:screenHeight))
        rightView = UIView(frame:CGRect(x:screenWidth/2, y:0, width:screenWidth/2, height:screenHeight))
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
                    vrSubView.frame = CGRectOffset(vrSubView.frame, CGFloat(-(gyroData?.rotationRate.x)!), CGFloat(-(gyroData?.rotationRate.y)!))
                }
            })
        }
    }
    
    func addVRSubview(view:UIView) {
        let leftSubView = view
        let rightSubView = view.copyView() as! UIView
        leftView.addSubview(leftSubView)
        rightView.addSubview(rightSubView)
        leftSubViews.append(leftSubView)
        rightSubViews.append(rightSubView)
    }
    
    required init?(coder aDecoder:NSCoder) {
        leftView = UIView()
        rightView = UIView()
        leftSubViews = []
        rightSubViews = []
        super.init(coder:aDecoder)
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