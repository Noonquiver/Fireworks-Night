//
//  GameScene.swift
//  Fireworks Night
//
//  Created by Camilo Hernández Guerrero on 26/07/22.
//

import SpriteKit

class GameScene: SKScene {
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel = SKLabelNode()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var launches = 0 {
        didSet {
            if launches == 20 {
                gameTimer?.invalidate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    [weak self] in
                    let gameOverLabel = SKLabelNode()
                    gameOverLabel.fontName = "Chalkduster"
                    gameOverLabel.fontSize = 60
                    gameOverLabel.position = CGPoint(x: 512, y: 384)
                    gameOverLabel.text = "GAME OVER"
                    gameOverLabel.horizontalAlignmentMode = .center
                    self?.addChild(gameOverLabel)
                }

            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: 12, y: 12)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0: firework.color = .cyan
        case 1: firework.color = .green
        default: firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        launches += 1
        
        let movementAmount: CGFloat = 1800
        var offset = -200
    
        switch Int.random(in: 0...3){
        case 0:
            for _ in 0...4 {
                createFirework(xMovement: 0, x: 512 + offset, y: bottomEdge)
                offset += 100
            }
        case 1:
            for _ in 0...4 {
                createFirework(xMovement: CGFloat(0 + offset), x: 512 + offset, y: bottomEdge)
                offset += 100
            }
        case 2:
            for offset in [400, 300, 200, 100, 0] {
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + offset)
            }
        default:
            for offset in [400, 300, 200, 100, 0] {
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + offset)
            }
        }
    }
    
    func checkTouches (_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    func explode(firework: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = firework.position
        addChild(emitter)
        firework.removeFromParent()
        
        let wait = SKAction.wait(forDuration: emitter.particleLifetime)
        
        let destroyFirework = SKAction.run {
            emitter.removeFromParent()
        }
        
        let sequence = SKAction.sequence([wait, destroyFirework])
        run(sequence)
    }
    
    func explodeFireworks() {
        var fireworksExploted = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                fireworksExploted += 1
            }
        }
        
        switch fireworksExploted {
        case 1: score += 200
        case 2: score += 500
        case 3: score += 1500
        case 4: score += 2500
        case 5: score += 4000
        default: break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
}
