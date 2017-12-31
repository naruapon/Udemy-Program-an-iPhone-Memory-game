//
//  GameViewController.swift
//  MemoryGame
//
//  Created by @Yohann305 Eyeball Digital on 2/20/15.
//  Copyright (c) 2015 www.iOSOnlineCourses.com. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode =  .aspectFill
        
        // now we are displaying the view tht we just created:
        skView.presentScene(scene)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
