//
//  GameScene.swift
//  Project23 - SwiftyNinja
//
//  Created by Noah Pope on 11/8/24.
//

import SpriteKit
import GameplayKit

enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var score               = 0 {
        didSet { gameScore.text = "Score: \(score)" }
    }
    
    var activeSlicePoints   = [CGPoint]()
    var activeEnemies       = [SKSpriteNode]()
    var livesImages         = [SKSpriteNode]()
    var lives               = 3
    var isSwooshSoundActive = false
    
    override func didMove(to view: SKView) {
        let background          = SKSpriteNode(imageNamed: ImageKeys.sliceBackground)
        background.position     = CGPoint(x: 512, y: 384)
        background.blendMode    = .replace
        background.zPosition    = -1
        addChild(background)
        
        physicsWorld.gravity    = CGVector(dx: 0, dy: -6)
        physicsWorld.speed      = 0.85
        
        createScore()
        createLives()
        createSlices()
    }
    
    
    func createScore() {
        gameScore                           = SKLabelNode(fontNamed: FontKeys.chalkduster)
        gameScore.horizontalAlignmentMode   = .left
        gameScore.fontSize                  = 48
        addChild(gameScore)
        
        gameScore.position                  = CGPoint(x: 8, y: 8)
        score                               = 0
    }
    
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode  = SKSpriteNode(imageNamed: ImageKeys.sliceLife)
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    
    func createSlices() {
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
    
    
    // can you override the initial forcBomb val in the definition?
    func createEnemy(forceBomb: ForceBomb = .random) {
        // should enemy be penguin or bomb (force bomb, penguin or just be random)?
        // where should it be created on screen?
        // what direction is it moving?
        let enemy: SKSpriteNode
        var enemyType   = Int.random(in: 0...6)
        
        if forceBomb == .never { enemyType = 1 }
        else if forceBomb == .always { enemyType = 0 }
        
        if enemyType == 0 {
            // bomb code
        } else {
            enemy       = SKSpriteNode(imageNamed: ImageKeys.penguin)
            run(SKAction.playSoundFileNamed(SoundKeys.launch, waitForCompletion: false))
            enemy.name  = NameKeys.enemy
        }
        
        // position code
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch     = touches.first else { return }
        // remove all existing points in the activeSlicePoints array
        activeSlicePoints.removeAll(keepingCapacity: true)
        // get touch location and add it to the activeSlicePoints array
        let location        = touch.location(in: self)
        activeSlicePoints.append(location)
        // call redrawActiveSlice() to clear the slice shapes
        redrawActiveSlice()
        // remove any actions currently attached to the slice shapes
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        // set both slice shapes to have alpha of 1 so they are fully visible
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch     = touches.first else { return }
        let location        = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive { playSwooshSound() }
    }
    
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber                                            = Int.random(in: 1...3)
        let soundName                                               = "swoosh\(randomNumber).caf"
        
        let swooshSound                                             = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in self?.isSwooshSoundActive = false }
    }
    
    
    func redrawActiveSlice() {
        // if we have fewer than two points in our array = not enough data so clear the shapes and exit
        if activeSlicePoints.count < 2 {
            activeSliceBG.path  = nil
            activeSliceFG.path  = nil
            return
        }
        // more than 12 slice points = remove the oldest ones til we have at most 12 (keeps swipe shapes short) - use removeFirst()
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        // start line at the position of the 1st swipe pt, then go through the others drawing lines to each pt
        let path    = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count { path.addLine(to: activeSlicePoints[i]) }
        // update the slice shape paths so they get drawn using their designs (line width & color)
        activeSliceBG.path  = path.cgPath
        activeSliceFG.path  = path.cgPath
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
}
