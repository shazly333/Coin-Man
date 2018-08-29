//
//  GameScene.swift
//  Coin Man
//
//  Created by El-Shazly on 7/5/18.
//  Copyright © 2018 Shazly. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastPlace = 0
    private var character : SKSpriteNode?
    private var ground : SKSpriteNode?
    private var ceil : SKSpriteNode?
    private var scoreLabel : SKLabelNode?
    private var yourScoreLabel : SKLabelNode?
    private var finalScoreLabel : SKLabelNode?
    
    var score = 0
    
    let coinManCategory : UInt32 = 0x1 << 1
    let coinCategory : UInt32 = 0x1 << 2
    let bombCategory : UInt32 = 0x1 << 3
    let groundAndCeilCategory : UInt32 = 0x1 << 4
    
    var coinTimer : Timer?
    var bombTimer : Timer?

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        scoreLabel?.text = "Score: \(score)"

        self.character = self.childNode(withName: "//Character") as? SKSpriteNode
        character?.physicsBody?.categoryBitMask = coinManCategory
        character?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        character?.physicsBody?.collisionBitMask = groundAndCeilCategory
        var images: [SKTexture]=[]
        for number in 1...4{
            images.append(SKTexture(imageNamed:"frame-\(number)"))
        }
        character?.run(SKAction.repeatForever(SKAction.animate(with: images, timePerFrame: 0.2)))
        
        ground = self.childNode(withName: "//Ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ground?.physicsBody?.collisionBitMask = coinManCategory
        
        
        ceil = self.childNode(withName: "//Ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory
        
        scoreLabel = childNode(withName: "ScoreLabel") as? SKLabelNode
        
        createCoinsAndBombs()

        
    }
    func createCoinsAndBombs(){
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            if Int(timer.timeInterval) % 2 == 1{
            self.createCoin()
            }
        })
        bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            if Int(timer.timeInterval) % 2 == 0{
                self.createBomb()
            }        })
    }
    
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scene?.isPaused == false{
            character?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100000))
        }
        else{
            let touch = touches.first
            if let location = touch?.location(in: self){
                let allNodes = nodes(at: location)
                for node in allNodes {
                    if node.name == "play" {
                        score = 0
                        node.removeFromParent()
                        finalScoreLabel?.removeFromParent()
                        yourScoreLabel?.removeFromParent()
                        scene?.isPaused = false
                        scoreLabel?.text = "Score: \(score)"
                        createCoinsAndBombs()
                        removeAllBombsAndCoins()
                    }
                }

                
            }
            
            
            
        }
    
    }
    func removeAllBombsAndCoins(){
        while let node = scene?.childNode(withName: "coin"){
            node.removeFromParent()
        }
        while let node = scene?.childNode(withName: "bomb"){
            node.removeFromParent()
        }
    }
    
    func createCoin(){
        let newCoin = SKSpriteNode(imageNamed: "coin.png")
        newCoin.name = "coin"
        newCoin.physicsBody = SKPhysicsBody(rectangleOf: newCoin.size)
        newCoin.physicsBody?.affectedByGravity = false
        newCoin.physicsBody?.categoryBitMask = coinCategory
        newCoin.physicsBody?.contactTestBitMask = coinManCategory
        newCoin.physicsBody?.collisionBitMask = 0
        addChild(newCoin)
        let maxY = size.height / 2 - newCoin.size.height / 2
        let minY = -size.height / 2 + newCoin.size.height / 2
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        lastPlace = Int(coinY)
        newCoin.position = CGPoint(x: size.width/2 + newCoin.size.width/2, y: coinY)
        let moveLeft = SKAction.move(by: CGVector(dx: -size.width - newCoin.size.width, dy: 0), duration: 4)
        newCoin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    func createBomb(){
        let newBomb = SKSpriteNode(imageNamed: "bomb")
        newBomb.name = "bomb"
        newBomb.physicsBody = SKPhysicsBody(rectangleOf: newBomb.size)
        newBomb.physicsBody?.affectedByGravity = false
        newBomb.physicsBody?.categoryBitMask = bombCategory
        newBomb.physicsBody?.contactTestBitMask = coinManCategory
        newBomb.physicsBody?.collisionBitMask = 0
        addChild(newBomb)
        let maxY = size.height / 2 - newBomb.size.height / 2
        let minY = -size.height / 2 + newBomb.size.height / 2
        let range = maxY - minY
        var bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        

        newBomb.position = CGPoint(x: size.width/2 + newBomb.size.width/2, y: bombY)
//        while let node = scene?.childNode(withName: "coin"){
//            if node.intersects(newBomb){
//                bombY+=20
//            }
//        }
        let moveLeft = SKAction.move(by: CGVector(dx: -size.width - newBomb.size.width-10, dy: 0), duration: 4)

        newBomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))

    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == coinCategory{
            score+=1
            contact.bodyA.node?.removeFromParent()
            
        }
        if contact.bodyB.categoryBitMask == coinCategory{
            score+=1
            contact.bodyB.node?.removeFromParent()
            
        }
        if contact.bodyA.categoryBitMask == bombCategory {
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
        if contact.bodyB.categoryBitMask == bombCategory {
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
        scoreLabel?.text = "Score: \(score)"

    }
    func gameOver(){
        scene?.isPaused = true
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil {
            addChild(finalScoreLabel!)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
    
        
    }
}
