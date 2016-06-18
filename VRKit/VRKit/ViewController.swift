//
//  ViewController.swift
//  VRKit
//
//  Created by Gianluca Rago on 6/17/16.
//  Copyright © 2016 Gianluca Rago. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sample implementation
        
        
        // Create a VRView object, which will take up the full screen size by default
        
        let vrView = VRView()
        self.view.addSubview(vrView)
        
        // Add UI objects to the VRView the same way as you would to a UIView
        
        let myView = UIView(frame:CGRect(x:20, y:20, width:40, height:40))
        myView.backgroundColor = UIColor.redColor()
        
        // The only difference is use addVRSubview(UIView) in place of addSubview(UIView)
        
        vrView.addVRSubview(myView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

