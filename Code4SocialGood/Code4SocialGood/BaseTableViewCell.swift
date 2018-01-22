//
//  BaseTableViewCell.swift
//  Code4SocialGood
//
//  Created by Derek Carter on 1/22/18.
//  Copyright © 2018 Code 4 Social Good. All rights reserved.
//

import UIKit
import CoreMotion

class BaseTableViewCell: UITableViewCell {
    
    // Shadow view propertis
    private weak var shadowView: UIView?
    private static let kShadowViewInnerMargin: CGFloat = 14.0
    private static let kShadowViewCornerRadius: CGFloat = 14.0
    
    // Rounded card view properties
    @IBOutlet private weak var roundedView: UIView!
    
    // Motion properties
    private let motionManager = CMMotionManager()
    
    // Gesture properties
    private var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    private var isTapped: Bool = false
    private var singleTapGestureRecognizer: UITapGestureRecognizer? = nil
    private var isLongPressed: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureGestureRecognizers()
        
        roundedView.layer.cornerRadius = BaseTableViewCell.kShadowViewCornerRadius
        roundedView.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureShadowView()
    }
    
    
    // MARK: - Shadow View Methods
    
    private func configureShadowView() {
        // Build the shadow view
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: BaseTableViewCell.kShadowViewInnerMargin,
                                              y: BaseTableViewCell.kShadowViewInnerMargin,
                                              width: bounds.width - (2 * BaseTableViewCell.kShadowViewInnerMargin),
                                              height: bounds.height - (2 * BaseTableViewCell.kShadowViewInnerMargin)))
        shadowView.backgroundColor = UIColor.clear
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView
        
        // Pitch and roll for a more dynamic shadow
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    let pitch = CGFloat(motion.attitude.pitch * 4)
                    let roll = CGFloat(motion.attitude.roll * 4)
                    self.applyShadow(width: roll, height: pitch)
                }
            })
        }
        else {
            self.applyShadow(width: 0, height: 0)
        }
    }
    
    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: BaseTableViewCell.kShadowViewCornerRadius)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = UIColor.darkGray.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.2
            shadowView.layer.shadowRadius = 8.0
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }
    
    
    // MARK: - Gesture Recognizer Methods
    
    private func configureGestureRecognizers() {
        // Single tap gesture recognizer
        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGesture(gestureRecognizer:)))
        singleTapGestureRecognizer?.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGestureRecognizer!)
        
        // Long press gesture recognizer
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        longPressGestureRecognizer?.minimumPressDuration = 0.2
        self.addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    @objc internal func handleSingleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            handleSingleTapEnded()
        }
    }
    
    private func handleSingleTapEnded() {
        guard !isTapped else {
            return
        }
        
        isTapped = true
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.4,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        },
                       completion: { (finished) in
                        UIView.animate(withDuration: 0.2,
                                       delay: 0.0,
                                       usingSpringWithDamping: 0.8,
                                       initialSpringVelocity: 0.4,
                                       options: .beginFromCurrentState,
                                       animations: {
                                        self.transform = CGAffineTransform.identity
                        },
                                       completion: { (finished) in
                                        self.isTapped = false
                                        
                                        // TODO: Create the delegate for handling the tap ended
                        })
        })
    }
    
    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            handleLongPressBegan()
        }
        else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }
    
    private func handleLongPressBegan() {
        guard !isLongPressed else {
            return
        }
        
        isLongPressed = true
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                       completion: { (finished) in
                        // TODO: Create the delegate for handling long press began
        })
    }
    
    private func handleLongPressEnded() {
        guard isLongPressed else {
            return
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform.identity
        },
                       completion: { (finished) in
                        self.isLongPressed = false
                        
                        // TODO: Create the delegate for handling long press ended
        })
    }
    
}
