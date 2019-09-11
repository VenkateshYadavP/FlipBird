//
//  GameScene.swift
//  FlipBird
//
//  Created by Venkatesh P1 on 9/3/17.
//  Copyright © 2017 Venkatesh P1. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var score = 0
    var bg = SKSpriteNode()
    var scorelabel = SKLabelNode()
    var gameOverlabel = SKLabelNode()
    var timer = Timer()
    enum ColliderType: UInt32 {
        case Bird = 1
        case Objects = 2
        case Gap = 4
    }
    var gameOver = false
    override func didMove(to view: SKView) {
        setUpGame()
    }
    
    func setUpGame() {
        self.physicsWorld.contactDelegate = self
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.createPipes), userInfo: nil, repeats: true)
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        var i: CGFloat = 0
        while i < 3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(moveBGForever)
            bg.zPosition = -2
            self.addChild(bg)
            i += 1
        }
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.contactTestBitMask = ColliderType.Objects.rawValue
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
        self.addChild(bird)
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody?.contactTestBitMask = ColliderType.Objects.rawValue
        ground.physicsBody?.categoryBitMask = ColliderType.Objects.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Objects.rawValue
        self.addChild(ground)
        scorelabel.fontName = "Helvetica"
        scorelabel.fontSize = 60
        scorelabel.text = "0"
        scorelabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 70)
        self.addChild(scorelabel)

    }
    @objc func createPipes() {
        let gapHeight = bird.size.height * 4
        let movementOffset = arc4random() % UInt32(self.frame.height/2)
        let pipeOffset = CGFloat(movementOffset) - self.frame.height/4
        let movePipes = SKAction.move(by: CGVector(dx:-2 * self.frame.width,dy:0), duration: TimeInterval(self.frame.width/100))
        let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1Texture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe1.physicsBody?.isDynamic = false
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Objects.rawValue
        pipe1.physicsBody?.categoryBitMask = ColliderType.Objects.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.Objects.rawValue
        pipe1.zPosition = -1
        pipe1.run(movePipes)
        self.addChild(pipe1)
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Objects.rawValue
        pipe2.physicsBody?.categoryBitMask = ColliderType.Objects.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Objects.rawValue
        pipe2.zPosition = -1
        pipe2.run(movePipes)
        self.addChild(pipe2)
        let gapNode = SKNode()
        gapNode.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gapNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
        gapNode.physicsBody?.isDynamic = false
        gapNode.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gapNode.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gapNode.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        gapNode.run(movePipes)
        self.addChild(gapNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
            bird.physicsBody?.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 80))
        } else {
            gameOver = false
            score = 0
            scorelabel.text = "0"
            self.speed = 1
            self.removeAllChildren()
            self.setUpGame()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scorelabel.text = "\(score)"
            } else {
                timer.invalidate()
                self.speed = 0
                gameOver = true
                self.physicsWorld.contactDelegate = nil
                gameOverlabel.fontName = "Helvetica"
                gameOverlabel.fontSize = 30
                gameOverlabel.text = "Game Over! Tap to Play Again"
                gameOverlabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(gameOverlabel)
                
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
}
