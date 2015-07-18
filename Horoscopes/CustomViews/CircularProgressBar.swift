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
        var bigCircle = self.createCircle(CGPointMake(progressCenter.x, progressCenter.y), diameter: radius * 2 + strokeWidth)
        bigCircle.fillColor = UIColor(red:134/255.0, green:120/255.0, blue:170/255.0, alpha: 1.0).CGColor
        self.addSublayer(bigCircle)
        
        // The starting angle is given by the fraction of the circle that the point is at, divided by 2 * Pi and less
        // We subtract M_PI_2 to rotate the circle 90 degrees to make it more intuitive (i.e. like a clock face with zero at the top, 1/4 at RHS, 1/2 at bottom, etc.)
        
        progressCircle = CAShapeLayer()
        let startAngle = CGFloat(3 * M_PI / 2)
        let endAngle = CGFloat(7 * M_PI / 2)
        
        // `clockwise` tells the circle whether to animate in a clockwise or anti clockwise direction
        progressCircle.path = UIBezierPath(arcCenter: self.progressCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
        // Configure the circle
        // right color : UIColor(red:59/255.0, green:60/255.0, blue:86/255.0, alpha: 1.0)
        progressCircle.fillColor = UIColor.clearColor().CGColor
        progressCircle.strokeColor = UIColor(red:295/255.0, green:212/255.0, blue:93/255.0, alpha: 1.0).CGColor
        progressCircle.lineWidth = strokeWidth
        // When it gets to the end of its animation, leave it at 0% stroke filled
        progressCircle.strokeEnd = 0.0
        self.addSublayer(progressCircle)
        
        
        // create small circle
        var smallCircle = self.createCircle(CGPointMake(progressCenter.x, progressCenter.y), diameter: (radius - strokeWidth/2) * 2)
        smallCircle.fillColor = UIColor(red:59/255.0, green:60/255.0, blue:86/255.0, alpha: 1.0).CGColor
        self.addSublayer(smallCircle)
        
        
        
        // create a circle as the head of stroke
        var circleX = progressCenter.x
        var circleY = progressCenter.y - radius
        var strokeHead = self.createCircle(CGPointMake(circleX, circleY), diameter: strokeWidth)
        strokeHead.fillColor = UIColor(red:295/255.0, green:212/255.0, blue:93/255.0, alpha: 1.0).CGColor
        self.addSublayer(strokeHead)
        
        // moving headStroke
        circleX = progressCenter.x - strokeWidth/2
        circleY = progressCenter.y - radius - strokeWidth/2
        movingStrokeHead = self.createCircle(CGPointMake(circleX, circleY), diameter: strokeWidth)
        movingStrokeHead.fillColor = UIColor(red:295/255.0, green:212/255.0, blue:93/255.0, alpha: 1.0).CGColor
        self.addSublayer(movingStrokeHead)
    }
    
    func animateCircleWithProgress(progress: CGFloat, duration: CFTimeInterval) {
        // Configure the animation
        var drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.repeatCount = 1.0
        // Animate from the full stroke being drawn to none of the stroke being drawn
        drawAnimation.fromValue = NSNumber(double: 0.0)
        drawAnimation.toValue = NSNumber(double: Double(progress))
        drawAnimation.fillMode = kCAFillModeForwards;
        drawAnimation.removedOnCompletion = false;
        drawAnimation.duration = duration
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Add the animation to the circle
        progressCircle.addAnimation(drawAnimation, forKey: "drawCircleAnimation")
        self.animateCircleRotation(movingStrokeHead, rotationPoint: progressCenter, rotationValue: progress, duration: duration)
    }
    
    func createCircle(center: CGPoint, diameter: CGFloat) -> CAShapeLayer {
        // create a circle as the head of stroke
        var circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, diameter, diameter)).CGPath
        circle.position = center
        circle.bounds = CGPathGetBoundingBox(circle.path);
        return circle
    }
    
    func animateCircleRotation(shapeLayer: CAShapeLayer, rotationPoint: CGPoint, rotationValue: CGFloat, duration: CFTimeInterval) {
        let strokeFrame = CGRectMake(shapeLayer.position.x, shapeLayer.position.y, strokeWidth, strokeWidth)
        let minX   = CGRectGetMinX(strokeFrame);
        let minY   = CGRectGetMinY(strokeFrame);
        let width  = CGRectGetWidth(strokeFrame);
        let height = CGRectGetHeight(strokeFrame);
        
        let anchorPoint =  CGPointMake((rotationPoint.x-minX)/width, (rotationPoint.y-minY)/height);
        shapeLayer.anchorPoint = anchorPoint;
        shapeLayer.position = rotationPoint;
        
        var rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = Double(rotationValue) * (M_PI*2)
        rotateAnimation.removedOnCompletion = false;
        rotateAnimation.fillMode = kCAFillModeForwards;
        rotateAnimation.duration = duration;
        
        shapeLayer.addAnimation(rotateAnimation, forKey: "myRotationAnimation")
    }
    
}
