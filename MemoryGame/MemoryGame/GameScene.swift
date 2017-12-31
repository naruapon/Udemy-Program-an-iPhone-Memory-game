//
//  GameScene.swift
//  MemoryGame
//
//  Created by @Yohann305 Eyeball Digital on 2/20/15.
//  Copyright (c) 2015 www.iOSOnlineCourses.com. All rights reserved.
//

import SpriteKit
import GameKit
import iAd


class GameScene: SKScene, GKGameCenterControllerDelegate, ADBannerViewDelegate {
    
    
    var buttonPlay : SKSpriteNode!
    var buttonLeaderboard : SKSpriteNode!
    var buttonRate : SKSpriteNode!
    var title : SKSpriteNode!
    
    
    let cardsPerRow : Int = 4 // 4 - displays 1 more since index starts at 0 and is included
    let cardsPerColumn : Int = 5 // 5 - displays 1 more since index starts at 0 and is included
    let cardSizeX : CGFloat = 50
    let cardSizeY : CGFloat = 50
    
    let scorePanelAndAdvertisingHeight : CGFloat = 150
    
    var cards : [SKSpriteNode] = []
    var cardsBacks : [SKSpriteNode] = []
    var cardsStatus : [Bool] = []
    
    let numberOfTypesOfCards : Int = 26
    
    var cardsSequence : [Int] = []
    
    
    var selectedCardIndex1 : Int = -1
    var selectedCardIndex2 : Int = -1
    var selectedCard1Value : String = ""
    var selectedCard2Value : String = ""
    
    var gameIsPlaying : Bool = false
    var lockInteraction : Bool = false
    
    var scoreboard : SKSpriteNode!
    
    var tryCountCurrent : Int = 0
    var tryCountBest : Int!
    
    var tryCountCurrentLabel : SKLabelNode!
    var tryCountBestLabel : SKLabelNode!

    var DEBUG_MODE_ON : Bool = false
    var DelayPriorToHidingCards : TimeInterval = 1.5
    
    var finishedFlag : SKSpriteNode!
    
    var buttonReset : SKSpriteNode!
    
    var SoundActionButton : SKAction!
    var SoundActionMatch : SKAction!
    var SoundActionNoMatch : SKAction!
    var SoundActionWin : SKAction!
    
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String()
    var LeaderboardID = "com.appfresh.mytempappleaderboard"
    
    var adBannerView : ADBannerView!
    
    var APP_ID : String = "970576421"
    
    override func didMove(to view: SKView)
    {
        setupScenery()
        
        CreateMenu()
        
        CreateScoreboard()
        HideScoreboard()
        
        CreateFinishedFlag()
        HideFinishedFlag()
        
        SetupAudio()
        AuthenticateLocalPlayer()
        
        loadAds()
       
        if(DEBUG_MODE_ON == true)
        {
            DelayPriorToHidingCards = 0.15
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let touch = touches.anyObject() as UITouch
        
        let touch =  touches.first
        
        let positionInScene : CGPoint = touch!.location(in: self)
        let touchedNode : SKSpriteNode = self.atPoint(positionInScene) as! SKSpriteNode
        
        
        self.ProcessItemTouch(nod: touchedNode)
    }
    
   
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func setupScenery()
    {
        let background = SKSpriteNode(imageNamed: BackgroundImage)
        background.anchorPoint = CGPoint(x:0, y:1)
        background.position = CGPoint(x:0, y:size.height)
        background.zPosition = 0
        background.size = CGSize(width: self.view!.bounds.size.width, height: self.view!.bounds.size.height)
        addChild(background)
    }
    
    
    func CreateMenu()
    {
        let offsetY : CGFloat = 3.0
        let offsetX : CGFloat = 5.0
        buttonRate = SKSpriteNode(imageNamed: buttonRateImage)
        buttonRate.position = CGPoint(x:size.width/2, y:size.height / 2 + buttonRate.size.height + offsetY)
        buttonRate.zPosition = 10
        buttonRate.name = "rate"
        addChild(buttonRate)
        
        buttonPlay = SKSpriteNode(imageNamed: buttonPlayImage)
        buttonPlay.position = CGPoint(x:size.width / 2 - offsetX - buttonPlay.size.width / 2, y:size.height/2)
        buttonPlay.zPosition = 10
        buttonPlay.name = "play"
        addChild(buttonPlay)
        
        
        buttonLeaderboard = SKSpriteNode(imageNamed: buttonLeaderboardImage)
        buttonLeaderboard.position = CGPoint(x:size.width / 2 + offsetX + buttonLeaderboard.size.width / 2, y:size.height / 2)
        buttonLeaderboard.zPosition = 10
        buttonLeaderboard.name = "leaderboard"
        addChild(buttonLeaderboard)
        
        title = SKSpriteNode(imageNamed: titleImage)
        title.position = CGPoint(x:size.width/2, y:buttonRate.position.y + buttonRate.size.height / 2 + title.size.height / 2 + offsetY)
        title.zPosition = 10
        title.name = "title"
        addChild(title)
        title.setScale(1)
    }
    
    
    func ShowMenu()
    {
        let duration : TimeInterval = 0.5
        buttonPlay.run(SKAction.fadeAlpha(to: 1, duration: duration))
        buttonLeaderboard.run(SKAction.fadeAlpha(to: 1, duration: duration))
        buttonRate.run(SKAction.fadeAlpha(to: 1, duration: duration))
        title.run(SKAction.fadeAlpha(to: 1, duration: duration))
    }
    
    
    func HideMenu()
    {
        let duration : TimeInterval = 0.5
        buttonPlay.run(SKAction.fadeAlpha(to: 0, duration: duration))
        buttonLeaderboard.run(SKAction.fadeAlpha(to: 0, duration: duration))
        buttonRate.run(SKAction.fadeAlpha(to: 0, duration: duration))
        title.run(SKAction.fadeAlpha(to: 0, duration: duration))
    }
    
    
    func ProcessItemTouch(nod : SKSpriteNode)
    {
        if(gameIsPlaying == false)
        {
            if(nod.name == "play")
            {
                print("play button pressed")
                HideMenu()
                fillCardSequence()
                ResetCardsStatus()
                CreateCardboard()
                gameIsPlaying = true
                PlaceScoreboardAboveCards()
                ShowScoreboard()
                HideFinishedFlag()
                run(SoundActionButton)
            }
            else if (nod.name == "leaderboard")
            {
                print("leaderboard button pressed")
                run(SoundActionButton)
                showLeaderboard()
            }
            else if (nod.name == "rate" )
            {
                print("rate button pressed")
                run(SoundActionButton)
                launchRateGame()
            }
        }
        else
        {
            // game is playing
            if(nod.name == nil){
                return
            }
            if( nod.name == "reset")
            {
                ResetGame()
                run(SoundActionButton)
                return
            }
            let num: Int? = Int(nod.name!)
            if(num != nil) // it is a number
            {
                if(num! > 0)
                {
                    if(lockInteraction == true)
                    {
                        return
                    }
                    else
                    {
                        print("the card with number \(num) was touched")
                        var i : Int = 0
                        for cardBack in cardsBacks {
                            if(cardBack === nod) {
                                run(SoundActionButton)
                                // the nod is identical to the cardback at index i
                                let cardNode : SKSpriteNode = cards[i] as SKSpriteNode
                                if(selectedCardIndex1 == -1) {
                                    selectedCardIndex1 = i
                                    selectedCard1Value = cardNode.name!
                                    cardBack.run(SKAction.hide())
                                }
                                else if(selectedCardIndex2 == -1) {
                                    if(i != selectedCardIndex1) {
                                        lockInteraction = true
                                        selectedCardIndex2 = i
                                        selectedCard2Value = cardNode.name!
                                        cardBack.run(SKAction.hide())
                                        // at this point we want to compare the 2 cards for a match
                                        if(selectedCard1Value == selectedCard2Value || DEBUG_MODE_ON == true) {
                                            print("we have a match")
                                            Timer.scheduledTimer(timeInterval: DelayPriorToHidingCards, target: self, selector: #selector(GameScene.HideSelectedCards), userInfo: nil, repeats: false)
                                            
                                            SetStatusCardFound(cardIndex: selectedCardIndex1)
                                            SetStatusCardFound(cardIndex: selectedCardIndex2)
                                            run(SoundActionMatch)
                                            if(CheckIfGameOver() == true) {
                                                gameIsPlaying = false
                                                ShowMenu()
                                                run(SoundActionWin)
                                                PlaceScoreboardBelowPlayButton()
                                                SaveBestTryCount()
                                                ShowFinishedFlag()
                                                buttonReset.isHidden = true
                                                
                                            }
                                        } else {
                                            print("no match")
                                            Timer.scheduledTimer(timeInterval: DelayPriorToHidingCards, target: self, selector: #selector(GameScene.ResetSelectedCards), userInfo: nil, repeats: false)
                                            run(SoundActionNoMatch)
                                            IncreaseTryCount()
                                        }
                                    }
                                }
                            }
                            i += 1
                        }
                    }
                }
            }
        }
    }
    
    
    func CreateCardboard()
    {
        let totalEmptyScapeX : CGFloat = self.size.width - ( CGFloat(cardsPerRow + 1) ) * cardSizeX
        let offsetX : CGFloat = totalEmptyScapeX / (CGFloat(cardsPerRow) + 2)
        
        let totalEmptySpaceY : CGFloat = self.size.height - scorePanelAndAdvertisingHeight - ( CGFloat(cardsPerColumn + 1)) * cardSizeY
        let offsetY : CGFloat = totalEmptySpaceY / ( CGFloat(cardsPerColumn) + 2)
        
        cards = []
        cardsBacks = []
        
        var idx : Int = 0
        for i in 0...cardsPerRow
        {
            for j in 0...cardsPerColumn
            {
                let cardIndex : Int = cardsSequence[idx] // todo: need to fill the cardsSequence array!
                idx += 1
                let cardName : String = String(format: "card-%i",cardIndex)
                let card : SKSpriteNode = SKSpriteNode(imageNamed: cardName)
                card.size = CGSize(width: cardSizeX, height:cardSizeY)
                card.anchorPoint = CGPoint(x:0, y:0)
                
                let posX : CGFloat = offsetX + CGFloat(i) * card.size.width + offsetX * CGFloat(i)
                let posY : CGFloat = offsetY + CGFloat(j) * card.size.height + offsetY * CGFloat(j)
                card.position = CGPoint(x:posX, y:posY)
                card.zPosition = 9
                card.name = String(format: "%i", cardIndex)
                addChild(card)
                cards.append(card)
                
                let cardBack : SKSpriteNode = SKSpriteNode(imageNamed: "card-back")
                cardBack.size = CGSize(width:cardSizeX, height:cardSizeY)
                cardBack.anchorPoint = CGPoint(x:0, y:0)
                cardBack.zPosition = 10
                cardBack.position = CGPoint(x:posX, y:posY)
                cardBack.name = String(format: "%i", cardIndex)
                addChild(cardBack)
                cardsBacks.append(cardBack)
            }
        }
    }
    
    /*func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let total = list.count
        for i in 0..<(total - 1) {
            let j = Int(arc4random_uniform(UInt32(total - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }*/
    
    func shuffleArray<T>( array: inout Array<T>) -> Array<T>
    {
        var index = array.count - 1
        while index > 0 {
        //for var index = array.count - 1; index > 0; index -= 1 {
            // Random int from 0 to index-1
            let j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            swap(&array[index], &array[j])
            index -= 1
        }
        return array
    }
    
    func fillCardSequence()
    {
        cardsSequence.removeAll(keepingCapacity: false)
        let totalCards : Int = (cardsPerRow + 1) * (cardsPerColumn + 1) / 2
        for i in 1...(totalCards)
        {
            cardsSequence.append(i)
            cardsSequence.append(i)
        }
        let newSequence = shuffleArray(array: &cardsSequence)
        cardsSequence.removeAll(keepingCapacity: false)
        cardsSequence += newSequence
    }
    
    
    func fillCardSequenceDebug()
    {
        let totalCards : Int = (cardsPerRow + 1) * (cardsPerColumn + 1) / 2
        for i in 1...(totalCards)
        {
            cardsSequence.append(i)
            cardsSequence.append(i)
        }
    }
    
    
    func HideSelectedCards()
    {
        let card1 : SKSpriteNode = cards[selectedCardIndex1] as SKSpriteNode
        let card2 : SKSpriteNode = cards[selectedCardIndex2] as SKSpriteNode
        
        card1.run(SKAction.hide())
        card2.run(SKAction.hide())
        
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
        lockInteraction = false
        
    }
    
    
    func SetStatusCardFound(cardIndex : Int)
    {
        cardsStatus[cardIndex] = true
    }
    
    func ResetCardsStatus()
    {
        cardsStatus.removeAll(keepingCapacity: false)
        for _ in 0...(cardsSequence.count - 1)
        {
            cardsStatus.append(false)
        }
    }
    
    func ResetSelectedCards()
    {
        if(selectedCardIndex1 >= cardsBacks.count || selectedCardIndex2 >= cardsBacks.count || selectedCardIndex1 < 0 || selectedCardIndex2 < 0){
            return
        }
        let card1 : SKSpriteNode = cardsBacks[selectedCardIndex1] as SKSpriteNode
        let card2 : SKSpriteNode = cardsBacks[selectedCardIndex2] as SKSpriteNode
        
        card1.run(SKAction.unhide())
        card2.run(SKAction.unhide())
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
        lockInteraction = false

    }
    
    
    func CreateScoreboard()
    {
        scoreboard = SKSpriteNode(imageNamed: scoreboardImage)
        scoreboard.position = CGPoint(x:size.width / 2, y:size.height - 50 - scoreboard.size.height / 2)
        scoreboard.zPosition = 1
        scoreboard.name = "scoreboard"
        addChild(scoreboard)
        
        tryCountCurrentLabel = SKLabelNode(fontNamed: fontName)
        tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
        tryCountCurrentLabel?.fontSize = 30
        tryCountCurrentLabel?.fontColor = SKColor.white
        tryCountCurrentLabel?.zPosition = 11
        tryCountCurrentLabel?.position = CGPoint(x:scoreboard.position.x, y:scoreboard.position.y + 10)
        addChild(tryCountCurrentLabel)
        
        // todo: we need to get the best score from the storage (NSUSerDefault)
        tryCountBest = UserDefaults.standard.integer(forKey: "besttrycount") as Int
        
        tryCountBestLabel = SKLabelNode(fontNamed: fontName)
        tryCountBestLabel?.text = "Best: \(tryCountBest)"
        tryCountBestLabel?.fontSize = 30
        tryCountBestLabel?.fontColor = SKColor.white
        tryCountBestLabel?.zPosition = 11
        tryCountBestLabel?.position = CGPoint(x:tryCountCurrentLabel.position.x, y:tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
        addChild(tryCountBestLabel)
        
        buttonReset = SKSpriteNode(imageNamed: buttonRestartImage)
        buttonReset.position = CGPoint(x:scoreboard.position.x + scoreboard.size.width / 2 - buttonReset.size.width / 2, y:scoreboard.position.y - buttonReset.size.height / 3)
        buttonReset.name = "reset"
        buttonReset.setScale(0.5)
        buttonReset.zPosition = 11
        addChild(buttonReset)
        buttonReset.isHidden = true
    }
    
    func HideScoreboard()
    {
        scoreboard.isHidden = true
        tryCountBestLabel.isHidden = true
        tryCountCurrentLabel.isHidden = true
        buttonReset.isHidden = true
    }
    
    func ShowScoreboard()
    {
        scoreboard.isHidden = false
        tryCountBestLabel.isHidden = false
        tryCountCurrentLabel.isHidden = false
        buttonReset.isHidden = false
        
        if(tryCountBest == nil || tryCountBest == 0)
        {
            tryCountBestLabel.isHidden = true
        }
    }
    
    func CheckIfGameOver() -> Bool
    {
        var gameOver : Bool = true
        for i : Int in 0...(cardsStatus.count - 1)
        {
            if(cardsStatus[i] as Bool == false)
            {
                gameOver = false
                break
            }
        }
        
        return gameOver
    }
    
    func PlaceScoreboardBelowPlayButton()
    {
        scoreboard.position = CGPoint(x:size.width / 2, y:buttonPlay.position.y - scoreboard.size.height)
        
        tryCountCurrentLabel?.position = CGPoint(x:scoreboard.position.x, y:scoreboard.position.y + 10)
        tryCountBestLabel?.position = CGPoint(x:tryCountCurrentLabel.position.x, y:tryCountCurrentLabel.position.y - 10 - tryCountBestLabel.fontSize)
        tryCountBestLabel.isHidden = false
    }
    
    
    func PlaceScoreboardAboveCards()
    {
        scoreboard.position = CGPoint(x:size.width / 2, y:size.height - 50 - scoreboard.size.height / 2)
        
        tryCountCurrentLabel?.position = CGPoint(x:scoreboard.position.x, y:scoreboard.position.y + 10)
        tryCountBestLabel?.position = CGPoint(x:tryCountCurrentLabel.position.x, y:tryCountCurrentLabel.position.y - 10 - tryCountBestLabel.fontSize)
    }
    
    func SaveBestTryCount()
    {
        if(tryCountBest == nil || tryCountBest == 0 || tryCountCurrent < tryCountBest)
        {
            tryCountBest = tryCountCurrent
            UserDefaults.standard.set(tryCountBest, forKey: "besttrycount")
            UserDefaults.standard.synchronize()
            tryCountBestLabel?.text = "Best: \(tryCountBest)"
            submitScore()
        }
    }
    
    
    func CreateFinishedFlag()
    {
        finishedFlag = SKSpriteNode(imageNamed: finishedFlagImage)
        finishedFlag.size = CGSize(width:cardSizeX, height:cardSizeY)
        finishedFlag.anchorPoint = CGPoint(x: 0, y: 0)  //CGPointMake(0, 0)
        finishedFlag.position = CGPoint(x:size.width / 2, y:scoreboard.position.y - scoreboard.size.height / 2 - finishedFlag.size.height / 2)
        finishedFlag.zPosition = 11
        finishedFlag.name = "finishedflag"
        addChild(finishedFlag)
        finishedFlag.isHidden = true
        
    }
    
    func ShowFinishedFlag()
    {
        finishedFlag.position = CGPoint(x:size.width / 2, y:scoreboard.position.y - scoreboard.size.height / 2 - finishedFlag.size.height / 2)
        finishedFlag.isHidden = false
        
    }
    
    func HideFinishedFlag()
    {
        finishedFlag.isHidden = true
    }
    
    func IncreaseTryCount()
    {
        tryCountCurrent = tryCountCurrent + 1
        tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
    }
    
    func ResetGame()
    {
        run(SoundActionButton)
        RemoveAllCards()
        PlaceScoreboardAboveCards()
        ShowScoreboard()
        fillCardSequence()
        CreateCardboard()
        ResetCardsStatus()
        tryCountCurrent = 0
        tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
        finishedFlag.isHidden = true
    }
    
    
    func RemoveAllCards()
    {
        for card in cards
        {
            card.removeFromParent()
        }
        
        for card in cardsBacks
        {
            card.removeFromParent()
        }

        cards.removeAll(keepingCapacity: false)
        cardsBacks.removeAll(keepingCapacity: false)
        cardsStatus.removeAll(keepingCapacity: false)
        cardsSequence.removeAll(keepingCapacity: false)
        
        selectedCard1Value = ""
        selectedCard2Value = ""
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
    }
    
    
    func SetupAudio()
    {
        SoundActionButton = SKAction.playSoundFileNamed(soundButtonFile, waitForCompletion: false)
        SoundActionMatch = SKAction.playSoundFileNamed(soundMatchFile, waitForCompletion: false)
        SoundActionNoMatch = SKAction.playSoundFileNamed(soundNoMatchFile, waitForCompletion: false)
        SoundActionWin = SKAction.playSoundFileNamed(soundWinFile, waitForCompletion: false)
    }
    
    //MARK: leaderboard
    
    func AuthenticateLocalPlayer()
    {
        let localPlayer: GKLocalPlayer = GKLocalPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil)
            {
                let vc = self.view?.window?.rootViewController
                vc?.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                print("player is already authenticated")
                self.gcEnabled = true
                
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: (
                    { (leaderboardIdentifer, error) -> Void in
                        if error != nil {
                            print(error)
                        } else {
                            self.gcDefaultLeaderboard = leaderboardIdentifer!
                        }
                    }
                ))
                
               
                
                
            } else {
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error)
            }

        }

    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func showLeaderboard()
    {
        let gcVC : GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = LeaderboardID
        
        let vc = self.view?.window?.rootViewController
        vc?.present(gcVC, animated: true, completion: nil)
    }
    
    func submitScore()
    {
        let sScore = GKScore(leaderboardIdentifier: LeaderboardID)
        sScore.value = Int64(tryCountBest)
        
        GKLocalPlayer()
        
        GKScore.report([sScore], withCompletionHandler: { (error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }
            else
            {
                print("score submitted successfully")
            }
        })
    }
    
    func loadAds()
    {
        adBannerView = ADBannerView(frame: CGRect.zero)
        adBannerView.center = CGPoint(x:adBannerView.center.x, y:adBannerView.frame.size.height / 2)
        adBannerView.delegate = self
        view?.addSubview(adBannerView)
    }
    
    
    func launchRateGame()
    {
        Appirater.setAppId(APP_ID)
        Appirater.setDaysUntilPrompt(-1)
        Appirater.rateApp()
    }
    
}


























