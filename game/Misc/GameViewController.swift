//
//  GameViewController.swift
//  game
//
//  Created by BlobKat on 04/07/2021.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

var skview: SKView = SKView()
var controller: UIViewController = UIViewController()

class GameViewController: UIViewController, GADFullScreenContentDelegate {

    override func viewDidLoad() {
        SKScene.font = "HalogenbyPixelSurplus-Regular"
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            controller = self
            skview = view
            tutorialProgress = .init(rawValue: 0)
            let scene = ((tutorialProgress == .done ? Play(size: view.frame.size) : Story(size: view.frame.size)) as SKScene)
            scene.scaleMode = .aspectFit
            scene.backgroundColor = .black
            SKScene.transition.pausesIncomingScene = false
            view.presentScene(scene, transition: SKScene.transition)
            view.preferredFramesPerSecond = 120
            view.showsFPS = true
        }
    }
    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for key in presses{
            if let a = key.key?.keyCode{
                skview.scene?.keyDown(a)
            }
        }
    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for key in presses{
            if let a = key.key?.keyCode{
                skview.scene?.keyUp(a)
            }
        }
    }
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for key in presses{
            if let a = key.key?.keyCode{
                skview.scene?.keyUp(a)
            }
        }
    }
}
