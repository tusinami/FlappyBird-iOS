import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverNode: SKNode?
    var score = 0
    var isGameOver = false
    
    let birdCategory: UInt32 = 0x1 << 0
    let pipeCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2
    let scoreCategory: UInt32 = 0x1 << 3
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6.0) // Slightly stronger gravity for snappier feel
        
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
    
    func createBirdTexture() -> SKTexture {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setFillColor(UIColor.yellow.cgColor)
            cgContext.fill(CGRect(x: 5, y: 10, width: 25, height: 20))
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(CGRect(x: 5, y: 15, width: 10, height: 10))
            cgContext.setFillColor(UIColor.black.cgColor)
            cgContext.fill(CGRect(x: 23, y: 13, width: 4, height: 4))
            cgContext.setFillColor(UIColor.orange.cgColor)
            cgContext.fill(CGRect(x: 28, y: 18, width: 7, height: 7))
        }
        return SKTexture(image: image)
    }
    
    func setupBird() {
        bird = SKSpriteNode(texture: createBirdTexture())
        bird.position = CGPoint(x: self.size.width * 0.3, y: self.size.height / 2)
        bird.zPosition = 10
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
        scoreLabel.fontSize = 80
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 100
        
        // Add a subtle shadow
        let shadow = SKLabelNode(text: "0")
        shadow.fontName = "AvenirNext-Bold"
        shadow.fontSize = 80
        shadow.fontColor = .black
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        scoreLabel.addChild(shadow)
        
        addChild(scoreLabel)
    }
    
    func startPipes() {
        let spawn = SKAction.run { [weak self] in
            self?.createPipes()
        }
        let delay = SKAction.wait(forDuration: 1.8)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func createPipes() {
        if isGameOver { return }
        
        let pipeWidth: CGFloat = 60
        let gapHeight: CGFloat = 220 // Widened gap for lower difficulty
        let groundHeight: CGFloat = 100
        
        guard self.size.height > 400 else { return }
        
        let minY = groundHeight + 150
        let maxY = self.size.height - 150
        let randomY = CGFloat.random(in: minY...maxY)
        
        let topPipeHeight = self.size.height - randomY - (gapHeight / 2)
        let topPipe = SKSpriteNode(color: .green, size: CGSize(width: pipeWidth, height: topPipeHeight))
        topPipe.position = CGPoint(x: self.size.width + pipeWidth, y: self.size.height - topPipeHeight / 2)
        
        // Add pipe cap for better look
        let topCap = SKSpriteNode(color: UIColor(red: 0, green: 0.5, blue: 0, alpha: 1), size: CGSize(width: pipeWidth + 10, height: 20))
        topCap.position = CGPoint(x: 0, y: -topPipeHeight / 2 + 10)
        topPipe.addChild(topCap)
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        
        let bottomPipeHeight = randomY - (gapHeight / 2) - groundHeight
        let bottomPipe = SKSpriteNode(color: .green, size: CGSize(width: pipeWidth, height: bottomPipeHeight))
        bottomPipe.position = CGPoint(x: self.size.width + pipeWidth, y: groundHeight + bottomPipeHeight / 2)
        
        // Add pipe cap
        let bottomCap = SKSpriteNode(color: UIColor(red: 0, green: 0.5, blue: 0, alpha: 1), size: CGSize(width: pipeWidth + 10, height: 20))
        bottomCap.position = CGPoint(x: 0, y: bottomPipeHeight / 2 - 10)
        bottomPipe.addChild(bottomCap)
        
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
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 11)) // Reduced impulse
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (birdCategory | pipeCategory) || contactMask == (birdCategory | groundCategory) {
            if !isGameOver { gameOver() }
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
        if highScores.count > 10 { highScores = Array(highScores.prefix(10)) }
        UserDefaults.standard.set(highScores, forKey: "HighScores")
    }
    
    func showGameOverUI() {
        let board = SKNode()
        board.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        board.zPosition = 200
        gameOverNode = board
        addChild(board)
        
        let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 450), cornerRadius: 15)
        bg.fillColor = SKColor(red: 0.95, green: 0.9, blue: 0.7, alpha: 1.0)
        bg.strokeColor = SKColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1.0)
        bg.lineWidth = 4
        board.addChild(bg)
        
        let title = SKLabelNode(text: "GAME OVER")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 36
        title.fontColor = SKColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1.0)
        title.position = CGPoint(x: 0, y: 170)
        board.addChild(title)
        
        let scoreTitle = SKLabelNode(text: "SCORE")
        scoreTitle.fontName = "AvenirNext-Medium"
        scoreTitle.fontSize = 18
        scoreTitle.fontColor = .darkGray
        scoreTitle.position = CGPoint(x: 0, y: 120)
        board.addChild(scoreTitle)
        
        let scoreValue = SKLabelNode(text: "\(score)")
        scoreValue.fontName = "AvenirNext-Bold"
        scoreValue.fontSize = 48
        scoreValue.fontColor = .black
        scoreValue.position = CGPoint(x: 0, y: 80)
        board.addChild(scoreValue)
        
        let line = SKShapeNode(rectOf: CGSize(width: 240, height: 2))
        line.fillColor = SKColor(white: 0, alpha: 0.1)
        line.strokeColor = .clear
        line.position = CGPoint(x: 0, y: 60)
        board.addChild(line)
        
        let highScores = UserDefaults.standard.array(forKey: "HighScores") as? [Int] ?? []
        let lbTitle = SKLabelNode(text: "RANKING")
        lbTitle.fontName = "AvenirNext-Bold"
        lbTitle.fontSize = 14
        lbTitle.fontColor = .darkGray
        lbTitle.position = CGPoint(x: 0, y: 35)
        board.addChild(lbTitle)
        
        for (index, s) in highScores.enumerated() {
            let yPos = CGFloat(10 - index * 22)
            let rankLabel = SKLabelNode(text: "\(index + 1).")
            rankLabel.fontName = "AvenirNext-Medium"
            rankLabel.fontSize = 16
            rankLabel.fontColor = .black
            rankLabel.horizontalAlignmentMode = .left
            rankLabel.position = CGPoint(x: -80, y: yPos)
            board.addChild(rankLabel)
            
            let valLabel = SKLabelNode(text: "\(s)")
            valLabel.fontName = "AvenirNext-Bold"
            valLabel.fontSize = 16
            valLabel.fontColor = .black
            valLabel.horizontalAlignmentMode = .right
            valLabel.position = CGPoint(x: 80, y: yPos)
            board.addChild(valLabel)
        }
        
        let restart = SKLabelNode(text: "TAP TO RESTART")
        restart.fontName = "AvenirNext-Bold"
        restart.fontSize = 20
        restart.fontColor = SKColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0)
        restart.position = CGPoint(x: 0, y: -180)
        board.addChild(restart)
        
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        restart.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
        
        board.setScale(0)
        board.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func resetGame() {
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
