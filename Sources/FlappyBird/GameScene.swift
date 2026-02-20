import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird: SKLabelNode! // Using SKLabelNode for emoji bird
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var leaderboardLabel: SKLabelNode!
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
        bird = SKLabelNode(text: "🐦")
        bird.fontSize = 40
        bird.position = CGPoint(x: self.size.width * 0.3, y: self.size.height / 2)
        bird.zPosition = 10
        
        // Use a physics body that matches the visual size approximately
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = pipeCategory | groundCategory | scoreCategory
        bird.physicsBody?.collisionBitMask = groundCategory | pipeCategory
        
        addChild(bird)
    }
    
    func setupGround() {
        let groundHeight: CGFloat = 100
        let ground = SKSpriteNode(color: .brown, size: CGSize(width: self.size.width, height: groundHeight))
        ground.position = CGPoint(x: self.size.width / 2, y: groundHeight / 2)
        ground.zPosition = 5
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        
        addChild(ground)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.85)
        scoreLabel.fontSize = 60
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }
    
    func startPipes() {
        let spawn = SKAction.run { [weak self] in
            self?.createPipes()
        }
        let delay = SKAction.wait(forDuration: 2.5)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func createPipes() {
        if isGameOver { return }
        
        let pipeWidth: CGFloat = 60
        let gapHeight: CGFloat = 180
        let groundHeight: CGFloat = 100
        let playableHeight = self.size.height - groundHeight
        let randomY = CGFloat.random(in: (groundHeight + 150)...(self.size.height - 150))
        
        let topPipeHeight = self.size.height - randomY - (gapHeight / 2)
        let topPipe = SKSpriteNode(color: .green, size: CGSize(width: pipeWidth, height: topPipeHeight))
        topPipe.position = CGPoint(x: self.size.width + pipeWidth, y: self.size.height - topPipeHeight / 2)
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        
        let bottomPipeHeight = randomY - (gapHeight / 2) - groundHeight
        let bottomPipe = SKSpriteNode(color: .green, size: CGSize(width: pipeWidth, height: bottomPipeHeight))
        bottomPipe.position = CGPoint(x: self.size.width + pipeWidth, y: groundHeight + bottomPipeHeight / 2)
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        
        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: self.size.width + pipeWidth, y: randomY)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: gapHeight))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        
        let moveAction = SKAction.moveBy(x: -self.size.width - 200, y: 0, duration: 5.0)
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
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (birdCategory | pipeCategory) || contactMask == (birdCategory | groundCategory) {
            if !isGameOver {
                gameOver()
            }
        } else if contactMask == (birdCategory | scoreCategory) {
            score += 1
            scoreLabel.text = "\(score)"
        }
    }
    
    func gameOver() {
        isGameOver = true
        self.physicsWorld.speed = 0
        bird.physicsBody?.isDynamic = false
        
        saveScore(score)
        showGameOverUI()
    }
    
    func saveScore(_ score: Int) {
        var highScores = UserDefaults.standard.array(forKey: "HighScores") as? [Int] ?? []
        highScores.append(score)
        highScores.sort(by: >)
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        UserDefaults.standard.set(highScores, forKey: "HighScores")
    }
    
    func showGameOverUI() {
        let background = SKShapeNode(rectOf: CGSize(width: self.size.width * 0.8, height: self.size.height * 0.6), cornerRadius: 20)
        background.fillColor = SKColor(white: 0, alpha: 0.7)
        background.strokeColor = .white
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 200
        addChild(background)
        
        gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: 0, y: background.frame.height / 2 - 60)
        gameOverLabel.zPosition = 201
        background.addChild(gameOverLabel)
        
        let currentScoreLabel = SKLabelNode(text: "Score: \(score)")
        currentScoreLabel.fontSize = 30
        currentScoreLabel.position = CGPoint(x: 0, y: gameOverLabel.position.y - 50)
        currentScoreLabel.zPosition = 201
        background.addChild(currentScoreLabel)
        
        let highScores = UserDefaults.standard.array(forKey: "HighScores") as? [Int] ?? []
        var leaderboardText = "TOP 10:\n"
        for (index, s) in highScores.enumerated() {
            leaderboardText += "\(index + 1). \(s)\n"
        }
        
        leaderboardLabel = SKLabelNode(text: leaderboardText)
        leaderboardLabel.numberOfLines = 0
        leaderboardLabel.fontSize = 20
        leaderboardLabel.horizontalAlignmentMode = .center
        leaderboardLabel.position = CGPoint(x: 0, y: currentScoreLabel.position.y - 200)
        leaderboardLabel.zPosition = 201
        background.addChild(leaderboardLabel)
        
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontSize = 25
        restartLabel.position = CGPoint(x: 0, y: -background.frame.height / 2 + 40)
        restartLabel.zPosition = 201
        background.addChild(restartLabel)
    }
    
    func resetGame() {
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
