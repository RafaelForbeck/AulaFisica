//
//  GameScene.swift
//  AulaFisica
//
//  Created by Rafael Forbeck on 15/05/19.
//  Copyright © 2019 Rafael Forbeck. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var target: SKShapeNode!
    var isTargeting = false
    var force = CGFloat(10)
    
    var btnGorilla: SKSpriteNode!
    var btnSnake: SKSpriteNode!
    
    var btnSelected: String!
    
    override func didMove(to view: SKView) {
        
        player = childNode(withName: "Player") as? SKSpriteNode
        setTarget()
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        btnGorilla = childNode(withName: "btnGorilla") as? SKSpriteNode
        btnSnake = childNode(withName: "btnSnake") as? SKSpriteNode
        
        btnSelected = btnGorilla.name!
        let ground = childNode(withName: "Ground")
        ground?.physicsBody?.categoryBitMask = Masks.groundMask
        ground?.physicsBody?.contactTestBitMask = Masks.snakeMask
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "Ground" && contact.bodyB.node?.name == "Snake" {
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "Ground" && contact.bodyA.node?.name == "Snake" {
            contact.bodyA.node?.removeFromParent()
        }
    }
    
    func addBlock(pos: CGPoint) {
        let newBlock = SKSpriteNode(imageNamed: "gorilla")
        newBlock.position = pos
        newBlock.setScale(0.3)
        let body = SKPhysicsBody(rectangleOf: newBlock.frame.size)
        body.affectedByGravity = true
        newBlock.physicsBody = body
        addChild(newBlock)
    }
    
    func addSnake(pos: CGPoint) {
        let newSnake = SKSpriteNode(imageNamed: "snake")
        newSnake.position = pos
        newSnake.setScale(0.3)
        newSnake.name = "Snake"
        let body = SKPhysicsBody(circleOfRadius: newSnake.frame.width * 0.5, center: CGPoint(x: 0, y: 2))
        body.affectedByGravity = true
        body.linearDamping = 2
        body.categoryBitMask = Masks.snakeMask
        body.contactTestBitMask = Masks.groundMask
        newSnake.physicsBody = body
        addChild(newSnake)
    }
    
    func setTarget() {
        target = SKShapeNode(circleOfRadius: 10)
        target.fillColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        target.zPosition = 1
        target.strokeColor = UIColor.clear
        target.isHidden = true
        self.addChild(target)
    }
    
    func setPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: player.frame.width * 0.45)
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = true
        body.mass = 1
        player.physicsBody = body
    }
    
    func fire() {
        let deltaX = player.position.x - target.position.x
        let deltaY = player.position.y - target.position.y
        
        let impulse = CGVector(dx: deltaX * force, dy: deltaY * force)
        
        player.physicsBody?.applyImpulse(impulse)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if player.contains(pos) {
            isTargeting = true
            target.isHidden = false
            target.position = pos
        } else if btnGorilla.contains(pos) {
            btnSelected = btnGorilla.name!
        } else if btnSnake.contains(pos) {
            btnSelected = btnSnake.name!
        } else {
            if btnSelected == btnGorilla.name! {
                addBlock(pos: pos)
            } else {
                addSnake(pos: pos)
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        target.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if isTargeting {
            if player.physicsBody == nil {
                setPhysicsBody()
            }
            fire()
        }
        target.isHidden = true
        isTargeting = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
