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
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
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
        let movementAmount: CGFloat = 1800
        var offset = -200
        switch Int.random(in: 0...3) {
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
            offset = 400
            for _ in 0...4 {
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + offset)
                offset -= 100
            }
        default:
            offset = 400
            for _ in 0...4 {
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + offset)
                offset -= 100
            }
        }
    }
}
