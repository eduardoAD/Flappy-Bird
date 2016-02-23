//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Eduardo Alvarado Díaz on 1/22/16.
//  Copyright (c) 2016 personal. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var gameOver = false
    var gameOverLabel = SKLabelNode()
    var movingObjects = SKSpriteNode()
    var labelContainer = SKSpriteNode()

    enum ColliderType: UInt32{

        case Bird = 1
        case Object = 2
        case Gap = 4

    }

    var score = 0
    var scoreLabel = SKLabelNode()

    func makebg() {
        let bgTexture = SKTexture(imageNamed: "img/bg.png")

        let movebg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replacebg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let movebgForever = SKAction.repeatActionForever(SKAction.sequence([movebg, replacebg]))

        for var i: CGFloat = 0; i<3; i++ {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.zPosition = -5
            bg.size.height = self.frame.height
            bg.runAction(movebgForever)

            movingObjects.addChild(bg)
        }
    }


    override func didMoveToView(view: SKView) {

        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        self.addChild(labelContainer)

        makebg()

        let birdTexture = SKTexture(imageNamed: "img/flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "img/flappy2.png")

        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)

        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.dynamic = true
        bird.physicsBody!.allowsRotation = false

        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue

        self.addChild(bird)

        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false

        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue

        self.addChild(ground)

        let floor = SKNode()
        floor.position = CGPointMake(0, self.frame.height)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        floor.physicsBody!.dynamic = false

        self.addChild(floor)

        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)

        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 70)
        scoreLabel.zPosition = 3

        self.addChild(scoreLabel)
    }

    func makePipes() {
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4

        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])


        let pipe1Texture = SKTexture(imageNamed: "img/pipe1.png")
        pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) + pipe1Texture.size().height/2 + gapHeight / 2 + pipeOffset)
        pipe1.zPosition = 2
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1Texture.size())
        pipe1.physicsBody!.dynamic = false

        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue

        movingObjects.addChild(pipe1)

        let pipe2Texture = SKTexture(imageNamed: "img/pipe2.png")
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) - pipe1Texture.size().height/2 - gapHeight / 2 + pipeOffset)
        pipe2.zPosition = 2
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1Texture.size())
        pipe2.physicsBody!.dynamic = false

        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipe2)

        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width * 2/3 , gapHeight))
        gap.physicsBody!.dynamic = false

        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue

        movingObjects.addChild(gap)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue ||
            contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {

            score++
            scoreLabel.text = String(score)
        }else {
            if gameOver == false {
                gameOver = true
                self.speed = 0

                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidX(self.frame))
                gameOverLabel.zPosition = 3

                labelContainer.addChild(gameOverLabel)
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if gameOver == false {
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 50))
        } else {
            score = 0
            scoreLabel.text = "0"
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            bird.physicsBody!.velocity = CGVectorMake(0, 0)

            movingObjects.removeAllChildren()

            makebg()

            self.speed = 1
            gameOver = false
            labelContainer.removeAllChildren()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
