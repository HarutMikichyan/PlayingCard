//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Harut Mikichyan on 10/9/19.
//  Copyright © 2019 Ruben. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    //MARK: -Initializers
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    //MARK: - Private Interface
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midX)
            //
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - (CGFloat.pi/2).arc4random
            case let (x, y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).arc4random
            case let(x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + (CGFloat.pi/2).arc4random
            default:
                push.angle = (2 * CGFloat.pi).arc4random
            }
        }
        push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        
        addChildBehavior(push)
    }
}
