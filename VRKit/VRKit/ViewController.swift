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
        
        let vrView = VRView()
        self.view.addSubview(vrView)
        
        let myView = UIView(frame:CGRect(x:20, y:20, width:40, height:40))
        myView.backgroundColor = UIColor.redColor()
        vrView.addVRSubview(myView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

