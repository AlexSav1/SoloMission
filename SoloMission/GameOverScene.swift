//
//  GameOverScene.swift
//  SoloMission
//
//  Created by Aditya Narayan on 3/13/17.
//
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
 
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let bckRnd = SKSpriteNode(imageNamed: "space")
        bckRnd.size = self.size
        bckRnd.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bckRnd.zPosition = 0
        self.addChild(bckRnd)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if (gameScore > highScoreNumber){
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScorelabel = SKLabelNode(fontNamed: "The Bold Font")
        highScorelabel.text = "High Score: \(highScoreNumber)"
        highScorelabel.fontSize = 125
        highScorelabel.fontColor = SKColor.white
        highScorelabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.45)
        highScorelabel.zPosition = 1
        self.addChild(highScorelabel)
        
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            
            if(restartLabel.contains(pointOfTouch)){
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
        }
        
    }
    
    
}
