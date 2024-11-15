//
//  GameScene.swift
//  Project23 - SwiftyNinja
//
//  Created by Noah Pope on 11/8/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene
{
    var gameScore: SKLabelNode!
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var bombSoundEffect: AVAudioPlayer?
    var enemy: SKSpriteNode!
    var activeSlicePoints   = [CGPoint]()
    var enemyTypes          = [String]()
    var activeEnemies       = [SKSpriteNode]()
    var livesImages         = [SKSpriteNode]()
    var sequence            = [SequenceType]()
    var sequencePosition    = 0
    var popupTime           = 0.9
    var chainDelay          = 3.0
    var nextSequenceQueued  = true
    var isSwooshSoundActive = false
    var isGameEnded         = false
    var lives               = 15 {
        didSet { if lives == 0 { endGame(triggeredByBomb: false) } }
    }
    var score               = 0 {
        didSet { gameScore.text = "Score: \(score)" }
    }
    
   
    
    override func didMove(to view: SKView)
    {
        configureWorld()
        createScore()
        createLives()
        createSlices()
        initiateSequence()
    }
    
    
    func configureWorld()
    {
        let background          = SKSpriteNode(imageNamed: ImageKeys.sliceBackground)
        background.position     = CGPoint(x: 512, y: 384)
        background.blendMode    = .replace
        background.zPosition    = -1
        addChild(background)
        
        physicsWorld.gravity    = CGVector(dx: 0, dy: -6)
        physicsWorld.speed      = 0.85
    }
    
    
    func createScore()
    {
        gameScore                           = SKLabelNode(fontNamed: FontKeys.chalkduster)
        gameScore.horizontalAlignmentMode   = .left
        gameScore.fontSize                  = 48
        addChild(gameScore)
        
        gameScore.position                  = CGPoint(x: 8, y: 8)
        score                               = 0
    }
    
    
    func createLives()
    {
        var livesCopy           = lives
        while livesCopy > 0 {
            let spriteNode      = SKSpriteNode(imageNamed: ImageKeys.sliceLife)
            spriteNode.position = CGPoint(x: CGFloat(1024 - (livesCopy * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
            livesCopy -= 1
        }
    }
    
    
    func subtractLife()
    {
        lives -= 1
        run(SKAction.playSoundFileNamed(SoundKeys.wrong, waitForCompletion: false))
        if lives == 0 { endGame(triggeredByBomb: false)}
        
        var life: SKSpriteNode
        life            = livesImages.reversed()[lives]
        life.texture    = SKTexture(imageNamed: ImageKeys.sliceLifeGone)
        life.xScale     = 1.3
        life.yScale     = 1.3
        life.run(SKAction.scaleX(to: 1, duration: 0.1))
    }
    
    
    func createSlices()
    {
        // track all players on the screen, recording an array of their swipe points
        activeSliceBG               = SKShapeNode()
        activeSliceBG.zPosition     = 2
        
        activeSliceFG               = SKShapeNode()
        activeSliceFG.zPosition     = 3
        
        activeSliceBG.strokeColor   = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth     = 9
        
        activeSliceFG.strokeColor   = UIColor.white
        activeSliceFG.lineWidth     = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    
    func configureEnemy(forceBomb: ForceBomb = .random)
    {
        for _ in 0 ..< 5 { enemyTypes.append(EnemyTypeKeys.penguin) }
        enemyTypes.append(EnemyTypeKeys.bomb)
        enemyTypes.append(EnemyTypeKeys.speedster)
        defer { enemyTypes.removeAll(); print("emptied enemytypes = \(enemyTypes)") }
        
        var enemyType                                                           = enemyTypes[Int.random(in: 0...6)]
        if forceBomb == .never { enemyType                                      = EnemyTypeKeys.penguin }
        else if forceBomb == .always { enemyType                                = EnemyTypeKeys.bomb }
        
        if enemyType == EnemyTypeKeys.bomb { generateBomb() }
        else if enemyType == EnemyTypeKeys.penguin { generatePenguin() }
        else { generateSpeedster() }
        
        position(enemy); addChild(enemy); activeEnemies.append(enemy)
    }
    
    
    func generateBomb()
    {
        enemy                                                                   = SKSpriteNode()
        enemy.zPosition                                                         = 1
        enemy.name                                                              = NameKeys.bombContainer
        
        let bombImage                                                           = SKSpriteNode(imageNamed: ImageKeys.bomb)
        bombImage.name                                                          = NameKeys.bomb
        enemy.addChild(bombImage)
        
        if bombSoundEffect != nil { bombSoundEffect?.stop(); bombSoundEffect    = nil }
        
        if let path                                                             = Bundle.main.url( forResource: SoundKeys.sliceBombFuse, withExtension: ".caf")
        {
            if let sound                                                        = try? AVAudioPlayer(contentsOf: path) { bombSoundEffect = sound; sound.play() }
        }
        
        if let emitter                                                          = SKEmitterNode(fileNamed: EmitterKeys.sliceFuse)
        {
            emitter.position                                                    = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
        }
    }
    
    
    func generatePenguin()
    {
        enemy       = SKSpriteNode(imageNamed: ImageKeys.penguin)
        run(SKAction.playSoundFileNamed(SoundKeys.launch, waitForCompletion: false))
        enemy.name  = NameKeys.penguin
    }
    
    
    func generateSpeedster() {
        enemy       = SKSpriteNode(imageNamed: ImageKeys.speedster)
        #warning("replace sound key with lightning")
        run(SKAction.playSoundFileNamed(SoundKeys.launch, waitForCompletion: false))
        enemy.name  = NameKeys.speedster
    }
    
    
    func position(_ enemy: SKSpriteNode)
    {
        let randomPosition                                                          = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position                                                              = randomPosition
        
        let randomAngularVelocity                                                   = CGFloat.random(in: -3...3)
        let randomXVelocity: Int
        
        if randomPosition.x < 256 {
            randomXVelocity                                                         = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity                                                         = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity                                                         = -Int.random(in: 3...5)
        } else {
            randomXVelocity                                                         = -Int.random(in: 8...15)
        }
                
        let randomYVelocity                                                         = Int.random(in: 24...32)
                
        enemy.physicsBody                                                           = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity                                                 = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity                                          = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask                                         = 0
    }
    
    
    func initiateSequence()
    {
        sequence                = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0 ... 1000 {
            // 'allCases' is why we made the enum conform to CaseIterable
            if let nextSequence = SequenceType.allCases.randomElement() { sequence.append(nextSequence) }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self      = self else { return }
            self.tossEnemies()
        }
    }
    
    
    func tossEnemies()
    {
        if isGameEnded { return }
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType    = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            configureEnemy(forceBomb: .never)
        case .one:
            configureEnemy()
            
        case .twoWithOneBomb:
            configureEnemy(forceBomb: .never)
            configureEnemy(forceBomb: .always)
            
        case .two:
            configureEnemy()
            configureEnemy()
            
        case .three:
            configureEnemy()
            configureEnemy()
            configureEnemy()
            
        case .four:
            configureEnemy()
            configureEnemy()
            configureEnemy()
            configureEnemy()
            
        case .chain:
            configureEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.configureEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.configureEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.configureEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.configureEnemy() }
            
        case .fastChain:
            configureEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.configureEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.configureEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.configureEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.configureEnemy() }
        }
        
        sequencePosition += 1
        nextSequenceQueued  = false
    }
    
    
    func playSwooshSound()
    {
        isSwooshSoundActive                                         = true
        
        let randomNumber                                            = Int.random(in: 1...3)
        let soundName                                               = "swoosh\(randomNumber).caf"
        
        let swooshSound                                             = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in self?.isSwooshSoundActive = false }
    }
    
    
    func redrawActiveSlice()
    {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path  = nil
            activeSliceFG.path  = nil
            return
        }
        if activeSlicePoints.count > 12 { activeSlicePoints.removeFirst(activeSlicePoints.count - 12) }
        let path                = UIBezierPath(); path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count { path.addLine(to: activeSlicePoints[i]) }
        activeSliceBG.path      = path.cgPath
        activeSliceFG.path      = path.cgPath
    }
    
    
    func obliterate(node: SKSpriteNode, atIndex index: Int)
    {
        if node.name == NameKeys.penguin { subtractLife() }
        node.removeAllActions()
        node.name   = ""
        node.removeFromParent()
        activeEnemies.remove(at: index)
    }
    
    
    func endGame(triggeredByBomb: Bool)
    {
        if isGameEnded { return }
        isGameEnded                 = true
        physicsWorld.speed          = 0
        isUserInteractionEnabled    = false
        
        bombSoundEffect?.stop()
        bombSoundEffect             = nil
        
        if triggeredByBomb {
            while lives >= 0 {
                var life: SKSpriteNode
                life            = livesImages.reversed()[lives]
                life.texture    = SKTexture(imageNamed: ImageKeys.sliceLifeGone)
                life.xScale     = 1.3
                life.yScale     = 1.3
                life.run(SKAction.scaleX(to: 1, duration: 0.1))
                lives -= 1
            }
        }
    }
}


// MARK: SPRITE KIT DELEGATE FUNCTIONS
extension GameScene {
    override func update(_ currentTime: TimeInterval)
    {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies
                .enumerated()
                .reversed() { if node.position.y < -140 { obliterate(node: node, atIndex: index) } }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    guard let self  = self else { return }
                    self.tossEnemies()
                }
                nextSequenceQueued  = true
            }
        }
        
        var bombCount               = 0
        
        for node in activeEnemies {
            if node.name == NameKeys.bombContainer {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            bombSoundEffect?.stop()
            bombSoundEffect         = nil
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch     = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)
        let location        = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if isGameEnded { return }
        guard let touch                 = touches.first else { return }
        let location                    = touch.location(in: self)
        
        activeSlicePoints.append(location); redrawActiveSlice()
        
        if !isSwooshSoundActive { playSwooshSound() }
        let nodesAtPoint                = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint
        {
            if node.name == NameKeys.penguin
            {
                if let emitter          = SKEmitterNode(fileNamed: EmitterKeys.sliceHitEnemy) {
                    emitter.position    = node.position
                    addChild(emitter)
                }
                
                node.name               = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut            = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut             = SKAction.fadeOut(withDuration: 0.2)
                let group               = SKAction.group([scaleOut, fadeOut])
                let seq                 = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                score += 1
                
                if let index            = activeEnemies.firstIndex(of: node) { activeEnemies.remove(at: index) }
                run(SKAction.playSoundFileNamed(SoundKeys.whack, waitForCompletion: false))
            }
            
            else if node.name == NameKeys.bomb
            {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                if let emitter          = SKEmitterNode(fileNamed: EmitterKeys.sliceHitBomb) {
                    emitter.position    = bombContainer.position
                    addChild(emitter)
                }
                
                node.name               = ""
                bombContainer.physicsBody?.isDynamic    = false
                
                let scaleOut            = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut             = SKAction.fadeOut(withDuration: 0.2)
                let group               = SKAction.group([scaleOut, fadeOut])
                let seq                 = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index            = activeEnemies.firstIndex(of: bombContainer) { activeEnemies.remove(at: index) }
                
                run(SKAction.playSoundFileNamed(SoundKeys.explosion, waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
}
