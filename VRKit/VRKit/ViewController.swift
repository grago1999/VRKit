//
//  ViewController.swift
//  VRKit
//
//  Created by Gianluca Rago on 6/17/16.
//  Copyright © 2016 Gianluca Rago. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    // Sample implementation
    
    // Create a VRView object, which will take up the full screen size by default
    
    let vrView = VRView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding the VRView to the main view
        
        self.view.addSubview(vrView)
        
        // By default the VRView will not create a continuous view, meaning it will not wrap around as the user reaches the edge of the content
        // You can enable it with the following function
        
        vrView.setContinuous(true)
        
        // Go to these functions to see implementation for certain UI elements
        
        addView()
        
        addImgView()
    }
    
    // Make sure to consider the position of the element when adding any elements to the VRView
    // This visible area for elements is half the screen width by the screen height, not the usual screen width by screen height
    
    func addView() {
        // Add UIView objects to the VRView the same way as you normally would
        
        let myView = UIView(frame:CGRect(x:20, y:20, width:40, height:40))
        myView.backgroundColor = UIColor.redColor()
        
        // The only difference is use addVRSubView(UIView) in place of addSubview(UIView)
        
        vrView.addVRSubView(myView)
    }
    
    func addImgView() {
        // Add UIImageView objects to the VRView the same way as you normally would
        
        let img = UIImage(named:"img360.jpg")
        let rate:CGFloat = img!.size.width/img!.size.height
        let height:CGFloat = screenHeight*1.75
        let imgView = UIImageView(frame:CGRect(x:0, y:0, width:rate*height, height:height))
        imgView.center = CGPoint(x:screenWidth/4, y:screenHeight/2)
        imgView.image = img
        
        // The only difference is use addVRSubImgView(UIView) in place of addSubview(UIView)
        
        vrView.addVRSubImgView(imgView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

