//
//  GameScene.swift
//  Game Template tvOS/iOS/OSX
//
//  Created by Matthew Fecher on 12/12/15.
//  Copyright (c) 2015 Denver Swift Heads. All rights reserved.
//

import SpriteKit

class GameScene: InitScene {
    
    // *************************************************************
    // Game States
    // *************************************************************
    
    enum GameState {
        case tutorial
        case play
    }
    
    // *************************************************************
    // Layers (zPosition)
    // *************************************************************
    
    enum Layer: CGFloat {
        case background
        case ground
        case hero
        case ui
    }
    
    // *************************************************************
    // Physics Body Categories (bitwise)
    // *************************************************************
    
    struct PhysicsCategory {
        static let None: UInt32 =   1 << 0 // 00000000000000000000000000000001
        static let Hero: UInt32 =   1 << 1 // 00000000000000000000000000000010
        static let Ground: UInt32 = 1 << 2 // 00000000000000000000000000000100
    }
    
    // *************************************************************
    // MARK: - Constants & Properties
    // *************************************************************
    
    let kImpulse: CGFloat = 200.0
    var dt: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var gameState: GameState = .tutorial
    let worldNode = SKNode()
    
    // Demo Specific
    let ship = SKSpriteNode(imageNamed:"Spaceship")
    let coinDropSound = SKAction.playSoundFileNamed("sfx_point.wav", waitForCompletion: false)
    let musicOn = true
    let kIntroSongName = "PositiveGameMusic.mp3"
    let sktAudio = SKTAudio()
    var jetParticle = SKEmitterNode()
    var userTouching = false
    var backgroundSongs: [String] = []
    
    // *************************************************************
    // MARK: - didMoveToView
    // *************************************************************
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    // *************************************************************
    // MARK: - User Interaction
    // *************************************************************
    
    override func userInteractionBegan(_ location: CGPoint) {
        
        switch gameState {
        case .tutorial:
            switchToPlayState()
            break
        case .play:
            userTouching = true
            break
        }
        
    }
    
    override func userInteractionMoved(_ location: CGPoint) {
        // touch/mouse moved
    }
    
    override func userInteractionEnded(_ location: CGPoint) {
        userTouching = false
    }
    
    // ***********************************************
    // MARK: - Update (aka the Game Loop)
    // ***********************************************
    
    // update method is called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        // Calculate delta time (dt) first
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        // Determine update based on gameState
        switch gameState {
        case .tutorial:
            break
        case .play:
            updateShip()
            break
        }
    }
    
    // *************************************************************
    // MARK: - Demo Setup Code - Can be deleted
    // *************************************************************
    
    // Setup Scenes/Nodes
    func setupScene() {
        setupWorld()
        setupBackground()
        setupBackgroundMusic()
        setupGround()
        setupHero()
        setupJetParticle()
        setupTutorial()
        
        if musicOn {
            playBackgroundMusic(kIntroSongName)
        }
    }
    
    func setupWorld() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2.5);
        addChild(worldNode)
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Layer.background.rawValue
        worldNode.addChild(background)
    }
    
    func setupStarParticle() {
        if let path = Bundle.main.path(forResource: "StarParticle", ofType: "sks") {
            let starParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            starParticle.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            starParticle.zPosition = Layer.ground.rawValue
            worldNode.addChild(starParticle)
        }
    }
    
    func setupJetParticle() {
        if let path = Bundle.main.path(forResource: "JetParticle", ofType: "sks") {
            jetParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            jetParticle.position = CGPoint(x: 0, y: -ship.frame.size.height)
            jetParticle.zPosition = Layer.hero.rawValue
            jetParticle.particleBirthRate = 50
            ship.addChild(jetParticle)
        }
    }
    
    func setupGround() {
        let ground = SKSpriteNode(imageNamed: "Ground2")
        ground.zPosition = Layer.ground.rawValue
        ground.position = CGPoint(x: size.width/2, y: ground.frame.height/4)
        
        // Add physics body for ground
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Hero
        worldNode.addChild(ground)
    }
    
    func setupHero() {
        ship.xScale = 0.5
        ship.yScale = 0.5
        ship.zPosition = Layer.hero.rawValue
        ship.position = CGPoint(x: size.width/2, y: self.frame.height * 0.4)
        
        // Add physics body for Ship
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        ship.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        
        // Ship starts out non-dynamic until Play starts
        ship.physicsBody?.isDynamic = false
        
        worldNode.addChild(ship)
    }
    
    func setupTutorial() {
        let label = SKLabelNode(fontNamed:"AvenirNext-Regular ")
        label.zPosition = Layer.ui.rawValue
        label.text = "Ready, Player One!"
        label.fontSize = 36
        label.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        label.name = "Tutorial"
        worldNode.addChild(label)
        
        let label2 = SKLabelNode(fontNamed:"AvenirNext-Regular ")
        label2.zPosition = Layer.ui.rawValue
        label2.text = "Tap or click to begin"
        label2.fontSize = 18
        label2.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        label2.name = "Tutorial"
        worldNode.addChild(label2)
    }
    
    func setupBackgroundMusic() {
        backgroundSongs = ["SillyGameMusic_120bpm.mp3", "Serious-Game-Music.mp3", "UplifitingGameMusic.mp3"]
    }
    
    // *************************************************************
    // MARK: - Demo Gameplay Code - Can be deleted
    // *************************************************************
    
    func fireThrusters() {
        // Apply impulse
        ship.physicsBody?.velocity = CGVector(dx: 0, dy: kImpulse/2)
        ship.physicsBody?.applyImpulse(CGVector(dx: 0, dy: kImpulse))
        
        // Show Jet Stream, zero means infinite particles
        jetParticle.numParticlesToEmit = 0
    }
    
    func releaseThrusters() {
        // Sets maximum particles to emmit, fades out emmision with 20 particles
        jetParticle.numParticlesToEmit = 20
    }
    
    func updateShip() {
        if userTouching {
            fireThrusters()
        } else {
            releaseThrusters()
        }
    }
    
    // *************************************************************
    // MARK: - Background Music
    // *************************************************************
    
    func playRandomBackgroundMusic() {
        let randomSong = Int.random(min: 0, max: backgroundSongs.count-1)
        sktAudio.playBackgroundMusic(backgroundSongs[randomSong])
        print("Background music: \(backgroundSongs[randomSong])")
    }
    
    func playBackgroundMusic(_ songName: String) {
        sktAudio.playBackgroundMusic(songName)
    }
    
    // *************************************************************
    // MARK: - Game States
    // *************************************************************
    
    func switchToPlayState() {
        // switch gameState
        gameState = .play
        
        // Play game start sound & music
        run(coinDropSound)
        if musicOn {
            playRandomBackgroundMusic()
        }
        
        // Make ship dynamic
        ship.physicsBody?.isDynamic = true

        // Setup particles
        setupStarParticle()
        jetParticle.particleBirthRate = 450
        
        // Remove Tutorial text
        worldNode.enumerateChildNodes(withName: "Tutorial", using: { node, stop in
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
                ]))
        })
    }

}
