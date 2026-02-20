import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    var isGameOver = false
    
    let birdCategory: UInt32 = 0x1 << 0
    let pipeCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2
    let scoreCategory: UInt32 = 0x1 << 3
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
        setupBackground()
        setupBird()
        setupGround()
        setupScoreLabel()
        
        startPipes()
    }
    
    func setupBackground() {
        let background = SKSpriteNode(color: .cyan, size: self.size)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupBird() {
        bird = SKSpriteNode(color: .yellow, size: CGSize(width: 30, height: 30))
        bird.position = CGPoint(x: self.size.width * 0.3, y: self.size.height / 2)
        bird.zPosition = 10
        
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = pipeCategory | groundCategory | scoreCategory
        bird.physicsBody?.collisionBitMask = groundCategory | pipeCategory
        
        addChild(bird)
    }
    
    func setupGround() {
        let ground = SKSpriteNode(color: .brown, size: CGSize(width: self.size.width, height: 50))
        ground.position = CGPoint(x: self.size.width / 2, y: 25)
        ground.zPosition = 5
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        
        addChild(ground)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.8)
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }
    
    func startPipes() {
        let spawn = SKAction.run { [weak self] in
            self?.createPipes()
        }
        let delay = SKAction.wait(forDuration: 2.0)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func createPipes() {
        if isGameOver { return }
        
        let pipeWidth: CGFloat = 50
        let gapHeight: CGFloat = 150
        let randomY = CGFloat.random(in: 200...450)
        
        let topPipe = SKSpriteNode(color: .green, size: CGSize(width: pipeWidth, height: 600))
        topPipe.position = CGPoint(x: self.size.width + pipeWidth, y: randomY + gapHeight / 2 + 300)
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        
        let bottomPipe = SKSpriteNode(color: .green, size: CGSize(width: pipeWidth, height: 600))
        bottomPipe.position = CGPoint(x: self.size.width + pipeWidth, y: randomY - gapHeight / 2 - 300)
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        
        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: self.size.width + pipeWidth, y: randomY)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: gapHeight))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        
        let moveAction = SKAction.moveBy(x: -self.size.width - 200, y: 0, duration: 4.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        
        topPipe.run(sequence)
        bottomPipe.run(sequence)
        scoreNode.run(sequence)
        
        addChild(topPipe)
        addChild(bottomPipe)
        addChild(scoreNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            resetGame()
        } else {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (birdCategory | pipeCategory) || contactMask == (birdCategory | groundCategory) {
            gameOver()
        } else if contactMask == (birdCategory | scoreCategory) {
            score += 1
            scoreLabel.text = "\(score)"
        }
    }
    
    func gameOver() {
        isGameOver = true
        self.physicsWorld.speed = 0
        bird.color = .red
    }
    
    func resetGame() {
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
