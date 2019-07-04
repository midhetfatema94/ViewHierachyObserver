//
//  ViewController.swift
//  ViewTest
//
//  Created by Waveline Media on 7/4/19.
//  Copyright © 2019 Waveline Media. All rights reserved.
//

import UIKit

public protocol InterfaceProtocol: class {
    func windowAction(shouldHide: Bool)
}

class ViewController: UIViewController {

    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var actionLabel: UILabel!
    
    var subviewOut: UIView!
    var subviewIn: UIView!
    var blueViewIndex = 0
    var viewCount = 0
    var windowAction = false
    
    @IBAction func addPopup(_ sender: Any) {
        let alert = UIAlertController(title: "Hello!", message: "I'm just a test popup!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func addViewOutside(_ sender: Any) {
        if subviewOut != nil {
            subviewOut.removeFromSuperview()
            subviewOut = nil
        } else {
            subviewOut = UIView(frame: CGRect(x: 150, y: 75, width: 20, height: 20))
            subviewOut.backgroundColor = UIColor.purple
            self.view.addSubview(subviewOut)
        }
    }
    
    @IBAction func addViewInside(_ sender: Any) {
        if subviewIn != nil {
            subviewIn.removeFromSuperview()
            subviewIn = nil
        } else {
            subviewIn = UIView(frame: CGRect(x: 150, y: 75, width: 20, height: 20))
            subviewIn.backgroundColor = UIColor.purple
            subviewIn.center = self.view.center
            self.view.addSubview(subviewIn)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, eachSubview) in self.view.subviews.enumerated() {
            if eachSubview == blueView {
                blueViewIndex = i
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(self.deviceResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(self.deviceBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let mainWindow = UIApplication.shared.keyWindow as? MyWindow {
            mainWindow.interfaceDelegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
//        if self.view.subviews.count == viewCount { return }
//        viewCount = self.view.subviews.count
        if windowAction { return }
        for (i, eachSubview) in self.view.subviews.enumerated() {
            if blueView.frame.intersects(eachSubview.frame) && blueViewIndex < i {
                actionLabel.text = "Pause"
                viewCount += 1
            }
        }
        if viewCount == 0 {
            actionLabel.text = "Play"
        } else {
            viewCount = 0
        }
//        if let subviewNotNil = self.view.subviews.last, subviewNotNil != blueView {
//            print("subviews detected change", blueView.frame.intersects(subviewNotNil.frame))
//            if blueView.frame.intersects(subviewNotNil.frame) {
//                actionLabel.text = "Pause"
//            } else {
//                actionLabel.text = "Play"
//            }
//        }
    }
    
    @objc func deviceResignActive() {
        print("resign active")
        actionLabel.text = "Pause"
        windowAction = true
    }
    
    @objc func deviceBecomeActive() {
        print("become active")
        actionLabel.text = "Play"
        windowAction = false
    }
}

extension ViewController: InterfaceProtocol {
    func windowAction(shouldHide: Bool) {
        if shouldHide {
            actionLabel.text = "Pause"
            windowAction = true
        } else {
            actionLabel.text = "Play"
            windowAction = false
        }
    }
}

class MyWindow: UIWindow {
    
    weak var interfaceDelegate: InterfaceProtocol?
    
    override func didAddSubview(_ subview: UIView) {
        print("New VC added")
        interfaceDelegate?.windowAction(shouldHide: true)
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        print("VC removed")
        interfaceDelegate?.windowAction(shouldHide: false)
    }
}
