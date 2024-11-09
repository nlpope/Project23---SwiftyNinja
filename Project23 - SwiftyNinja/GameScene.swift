//
//  GameScene.swift
//  Project23 - SwiftyNinja
//
//  Created by Noah Pope on 11/8/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var score       = 0 {
        didSet { gameScore.text = "Score: \(score)" }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives       = 3
    var testInfo    = "hi"
    
    override func didMove(to view: SKView) {
        let background  = SKSpriteNode(imageNamed: ImageKeys.sliceBackground)
        background.position = CGPoint(x: 512, y: 384)
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
    
    func testSave() {
        let jsonEncoder     = JSONEncoder()
        if let dataToSave   = try? jsonEncoder.encode(testInfo) {
            let defaults    = UserDefaults.standard
            defaults.set(dataToSave, forKey: "randoKey")
        } else {
            print("failed to save")
        }
    }
    
    
    func testLoad() {
        let userDefaults    = UserDefaults.standard
        if let dataToDecode = userDefaults.object(forKey: "randoKey") as? Data {
            let jsondecoder = JSONDecoder()
            do { testInfo    = try jsondecoder.decode(String.self, from: dataToDecode) }
            catch {
                print("failed to load")
            }
        }
    }
}
