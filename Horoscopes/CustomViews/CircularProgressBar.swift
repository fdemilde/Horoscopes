//
//  CircularProgressBar.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/10/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CircularProgressBar : CAShapeLayer {
    
    var progressCenter: CGPoint!
    var progressCircle: CAShapeLayer!
    var movingStrokeHead: CAShapeLayer!
    var strokeWidth : CGFloat!
    var radius : CGFloat!
    
    init(center: CGPoint, radius: CGFloat, strokeWidth: CGFloat){
        super.init()
        self.strokeWidth = strokeWidth
        self.radius = radius
        progressCenter = center
        self.createCircleProgress()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    // MARK: circle progress
    
    func createCircleProgress() {
        // create big circle
        let bigCircle = self.createCircle(CGPoint(x: progressCenter.x, y: progressCenter.y), diameter: radius * 2 + strokeWidth)
        bigCircle.fillColor = UIColor(red:102/255.0, green:92/255.0, blue:92/255.0, alpha: 1.0).cgColor
        self.addSublayer(bigCircle)
        
        // The starting angle is given by the fraction of the circle that the point is at, divided by 2 * Pi and less
        // We subtract M_PI_2 to rotate the circle 90 degrees to make it more intuitive (i.e. like a clock face with zero at the top, 1/4 at RHS, 1/2 at bottom, etc.)
        
        progressCircle = CAShapeLayer()
        let startAngle = CGFloat(3 * M_PI / 2)
        let endAngle = CGFloat(7 * M_PI / 2)
        
        // `clockwise` tells the circle whether to animate in a clockwise or anti clockwise direction
        progressCircle.path = UIBezierPath(arcCenter: self.progressCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        // Configure the circle
        // right color : UIColor(red:59/255.0, green:60/255.0, blue:86/255.0, alpha: 1.0)
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.strokeColor = UIColor(red:255/255.0, green:102/255.0, blue:102/255.0, alpha: 1.0).cgColor
        progressCircle.lineWidth = strokeWidth
        // When it gets to the end of its animation, leave it at 0% stroke filled
        progressCircle.strokeEnd = 0.0
        self.addSublayer(progressCircle)
        
        
        // create small circle
        let smallCircle = self.createCircle(CGPoint(x: progressCenter.x, y: progressCenter.y), diameter: (radius - strokeWidth/2) * 2)
        smallCircle.fillColor = UIColor(red:133/255.0, green:124/255.0, blue:173/255.0, alpha: 1.0).cgColor
        self.addSublayer(smallCircle)
        
        
        
        // create a circle as the head of stroke
        var circleX = progressCenter.x
        var circleY = progressCenter.y - radius
        let strokeHead = self.createCircle(CGPoint(x: circleX, y: circleY), diameter: strokeWidth)
        strokeHead.fillColor = UIColor(red:255/255.0, green:102/255.0, blue:102/255.0, alpha: 1.0).cgColor
        self.addSublayer(strokeHead)
        
        // moving headStroke
        circleX = progressCenter.x - strokeWidth/2
        circleY = progressCenter.y - radius - strokeWidth/2
        movingStrokeHead = self.createCircle(CGPoint(x: circleX, y: circleY), diameter: strokeWidth)
        movingStrokeHead.fillColor = UIColor(red:255/255.0, green:102/255.0, blue:102/255.0, alpha: 1.0).cgColor
        self.addSublayer(movingStrokeHead)
    }
    
    func animateCircleWithProgress(_ progress: CGFloat, duration: CFTimeInterval) {
        // Configure the animation
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.repeatCount = 1.0
        // Animate from the full stroke being drawn to none of the stroke being drawn
        drawAnimation.fromValue = NSNumber(value: 0.0 as Double)
        drawAnimation.toValue = NSNumber(value: Double(progress) as Double)
        drawAnimation.fillMode = kCAFillModeForwards;
        drawAnimation.isRemovedOnCompletion = false;
        drawAnimation.duration = duration
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Add the animation to the circle
        progressCircle.add(drawAnimation, forKey: "drawCircleAnimation")
        self.animateCircleRotation(movingStrokeHead, rotationPoint: progressCenter, rotationValue: progress, duration: duration)
    }
    
    func createCircle(_ center: CGPoint, diameter: CGFloat) -> CAShapeLayer {
        // create a circle as the head of stroke
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: diameter, height: diameter)).cgPath
        circle.position = center
        circle.bounds = (circle.path?.boundingBox)!;
        return circle
    }
    
    func animateCircleRotation(_ shapeLayer: CAShapeLayer, rotationPoint: CGPoint, rotationValue: CGFloat, duration: CFTimeInterval) {
        let strokeFrame = CGRect(x: shapeLayer.position.x, y: shapeLayer.position.y, width: strokeWidth, height: strokeWidth)
        let minX   = strokeFrame.minX;
        let minY   = strokeFrame.minY;
        let width  = strokeFrame.width;
        let height = strokeFrame.height;
        
        let anchorPoint =  CGPoint(x: (rotationPoint.x-minX)/width, y: (rotationPoint.y-minY)/height);
        shapeLayer.anchorPoint = anchorPoint;
        shapeLayer.position = rotationPoint;
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = Double(rotationValue) * (M_PI*2)
        rotateAnimation.isRemovedOnCompletion = false;
        rotateAnimation.fillMode = kCAFillModeForwards;
        rotateAnimation.duration = duration;
        
        shapeLayer.add(rotateAnimation, forKey: "myRotationAnimation")
    }
    
}
