//
//  ViewTransformGestureHelper.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 16.04.2024.
//

import Foundation
import UIKit

final class ViewTransformGestureHelper: NSObject {
    
    // MARK: - Properties
    
    private var gestureView: UIView
    private var transformView: UIView
    private var lastPanTranslation = CGPoint.zero
    private let initialTransform: CGAffineTransform
    
    
    // MARK: - Init
    
    init(gestureView: UIView, transformView: UIView) {
        self.gestureView = gestureView
        self.transformView = transformView
        self.initialTransform = transformView.transform
        super.init()
        addGestures()
    }
    
    
    // MARK: - Interface
    
    func reset() {
        transformView.transform = initialTransform
    }
    
    
    // MARK: - Private Methods
    
    private func addGestures() {
        let rotateGesture = UIRotationGestureRecognizer(target: self, 
                                                        action: #selector(didRotateView))
        let pinchGesture = UIPinchGestureRecognizer(target: self, 
                                                    action: #selector(didPinchView))
        let panGesture = UIPanGestureRecognizer(target: self, 
                                                action: #selector(didPanView))
        panGesture.minimumNumberOfTouches = 2
        
        rotateGesture.delegate = self
        pinchGesture.delegate = self
        
        gestureView.addGestureRecognizer(rotateGesture)
        gestureView.addGestureRecognizer(pinchGesture)
        gestureView.addGestureRecognizer(panGesture)
        
        gestureView.isUserInteractionEnabled = true
        gestureView.isMultipleTouchEnabled = true
    }
    
    
    // MARK: - Actions
    
    @objc private func didRotateView(_ gestureRecognizer: UIRotationGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            transformView.transform = transformView.transform.rotated(by: gestureRecognizer.rotation)
            gestureRecognizer.rotation = 0
        }
    }
    
    @objc private func didPinchView(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            transformView.transform = transformView.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc private func didPanView(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let translation = gestureRecognizer.translation(in: transformView)
        
        if gestureRecognizer.state == .changed {
            transformView.transform = transformView.transform.translatedBy(x: translation.x - lastPanTranslation.x,
                                                                           y: translation.y - lastPanTranslation.y)
        } else {
            lastPanTranslation = CGPoint.zero
        }
        
        lastPanTranslation = translation
    }
    
}

extension ViewTransformGestureHelper: UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
