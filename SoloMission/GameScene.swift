//
//  GameScene.swift
//  SoloMission
//
//  Created by Aditya Narayan on 3/13/17.
//
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "redFighter")
    
    let gameArea: CGRect
    
    enum GameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = GameState.preGame
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return self.random() * (max - min) + min
    }
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        self.gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        let bckRnd = SKSpriteNode(imageNamed: "space")
        bckRnd.size = self.size
        bckRnd.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bckRnd.zPosition = 0
        self.addChild(bckRnd)
        
        
        self.player.setScale(0.7)
        self.player.position = CGPoint(x: self.size.width/2, y: 0 - self.player.size.height)
        self.player.zPosition = 2
        self.player.physicsBody = SKPhysicsBody(rectangleOf: self.player.size)
        self.player.physicsBody!.affectedByGravity = false
        self.player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        self.player.physicsBody!.collisionBitMask = PhysicsCategories.None
        self.player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(self.player)

        
        self.scoreLabel.text = "Score: 0"
        self.scoreLabel.fontSize = 70
        self.scoreLabel.fontColor = SKColor.white
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + self.scoreLabel.frame.size.height)
        self.scoreLabel.zPosition = 100
        self.addChild(self.scoreLabel)
        
        self.livesLabel.text = "Lives: 3"
        self.livesLabel.fontSize = 70
        self.livesLabel.fontColor = SKColor.white
        self.livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        self.livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + self.livesLabel.frame.size.height)
        self.livesLabel.zPosition = 100
        self.addChild(self.livesLabel)
        
        let moveOntoScreen = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        self.scoreLabel.run(moveOntoScreen)
        self.livesLabel.run(moveOntoScreen)
        
        self.tapToStartLabel.text = "Tap To Begin"
        self.tapToStartLabel.fontSize = 100
        self.tapToStartLabel.fontColor = SKColor.white
        self.tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.tapToStartLabel.zPosition = 1
        self.tapToStartLabel.alpha = 0
        self.addChild(self.tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        self.tapToStartLabel.run(fadeInAction)
    }
    
    func startGame(){
        
        self.currentGameState = GameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        self.tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreen = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(self.startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreen, startLevelAction])
        self.player.run(startGameSequence)
    }
    
    func addScore(){
        
        gameScore += 1
        self.scoreLabel.text = "Score: \(gameScore)"
        
        if(gameScore == 10 || gameScore == 25 || gameScore == 50){
            self.startNewLevel()
        }
        
    }
    
    func runGameOver(){
        
        self.currentGameState = GameState.afterGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(self.changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func loseLife(){
        
        self.livesNumber -= 1
        self.livesLabel.text = "Lives: \(self.livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        self.livesLabel.run(scaleSequence)
        
        if(self.livesNumber == 0){
            self.runGameOver()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()

        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if(body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy){
            
            //if player hits enemy
            if(body1.node != nil){
                self.spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if(body2.node != nil){
                self.spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            self.runGameOver()
        }
        
        if(body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy){
            
            //if bullet hits enemy
            if(body2.node != nil){
                
                if(body2.node!.position.y > self.size.height){
                    return
                } else {
                    //spawnExplosion
                    self.spawnExplosion(spawnPosition: body2.node!.position)
                    self.addScore()
                    body1.node?.removeFromParent()
                    body2.node?.removeFromParent()
                }
            }
            
        }
        
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    func startNewLevel(){
        
        self.levelNumber += 1
        
        if(self.action(forKey: "spawningEnemies") != nil){
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("cannot find level info")
        }
        
        let spawn = SKAction.run(self.spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    func fireBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = self.player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy(){
        
        let randomXStart = self.random(min: self.gameArea.minX, max: self.gameArea.maxX)
        let randomXEnd = self.random(min: self.gameArea.minX, max: self.gameArea.maxX)

        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "Enemy"
        enemy.setScale(0.2)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALife = SKAction.run(self.loseLife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALife])
        if(self.currentGameState == GameState.inGame){
            enemy.run(enemySequence)
        }
        
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(self.currentGameState == GameState.preGame){
            self.startGame()
        }
        
        else if(self.currentGameState == GameState.inGame){
            self.fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if(self.currentGameState == GameState.inGame){
                self.player.position.x += amountDragged
            }
            
            if (self.player.position.x > (self.gameArea.maxX - self.player.size.width/2)){
                self.player.position.x = (self.gameArea.maxX - self.player.size.width/2)
            }
            
            if (self.player.position.x < (self.gameArea.minX + self.player.size.width/2)){
                self.player.position.x = (self.gameArea.minX + self.player.size.width/2)
            }
        }
        
    }
    
}
