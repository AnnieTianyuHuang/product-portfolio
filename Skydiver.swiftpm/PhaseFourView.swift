import SpriteKit
import SwiftUI

class PhaseFourScene: SKScene {
    private var skydiver: SKShapeNode?
    private var cloudButton: SKSpriteNode?
    private var stopAddingButton: SKSpriteNode?
    private var placeSkydiverButton: SKSpriteNode?
    private var isAddingClouds = false
    private var canPlaceSkydiver = false
    private var gameEnded = false
    var selection: Selection?
    
    let bottomBoundary: CGFloat = 50 

    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        resetGame() // 重置游戏到初始状态
    }
    
    func resetGame() {
            // 清除云朵和跳伞者
            self.removeAllChildren()
            self.isAddingClouds = false
            self.canPlaceSkydiver = false
            self.gameEnded = false
            setupCloudButton()
        print("resetted")
    }

    private func setupCloudButton() {
        cloudButton = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 50))
        guard let cloudButton = cloudButton else { return }
        cloudButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        cloudButton.name = "addCloud"

        let label = SKLabelNode(text: "Click to Add Cloud")
        label.fontColor = .white
        label.fontSize = 20
        cloudButton.addChild(label)

        self.addChild(cloudButton)
    }

    private func setupStopAddingButton() {
        stopAddingButton = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 50))
        guard let stopAddingButton = stopAddingButton else { return }
        stopAddingButton.position = CGPoint(x: self.frame.maxX - 120, y: self.frame.maxY - 60)
        stopAddingButton.name = "stopAdding"

        let label = SKLabelNode(text: "Stop Adding")
        label.fontColor = .white
        label.fontSize = 20
        stopAddingButton.addChild(label)

        self.addChild(stopAddingButton)
    }

    private func setupPlaceSkydiverButton() {
        placeSkydiverButton = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        guard let placeSkydiverButton = placeSkydiverButton else { return }
        placeSkydiverButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 100)
        placeSkydiverButton.name = "placeSkydiver"

        let label = SKLabelNode(text: "Click to Place Skydiver")
        label.fontColor = .white
        label.fontSize = 20
        placeSkydiverButton.addChild(label)

        self.addChild(placeSkydiverButton)
    }
    
    func addSkydiver(at position: CGPoint) {
        if !canPlaceSkydiver { return }
        skydiver?.removeFromParent()
        
        skydiver = SKShapeNode(circleOfRadius: 10)
        skydiver?.fillColor = SKColor.blue
        skydiver?.strokeColor = SKColor.blue
        skydiver?.position = position
        
        if let skydiverNode = skydiver {
            addChild(skydiverNode)
                       simulateSkydiving(from: position)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        if nodes.contains(where: { $0.name == "addCloud" }) && !isAddingClouds {
            cloudButton?.removeFromParent()
            isAddingClouds = true
            setupStopAddingButton()
        } else if nodes.contains(where: { $0.name == "stopAdding" }) {
            stopAddingButton?.removeFromParent()
            isAddingClouds = false
            setupPlaceSkydiverButton()
        } else if nodes.contains(where: { $0.name == "placeSkydiver" }) && !isAddingClouds {
            placeSkydiverButton?.removeFromParent()
            canPlaceSkydiver = true
        } else if isAddingClouds {
            addCloud(at: location)
        } else if canPlaceSkydiver {
            addSkydiver(at: location)
            canPlaceSkydiver = false // 确保只放置一次 skydiver
        }
    }
    
    func determineSkydiverAction(at position: CGPoint) {
        let heightPortion = size.height / 5
        let topFifth = size.height * 4 / 5
        let bottomFifth = heightPortion

        if position.y > topFifth {
            flyChaotically(from: position)
        } else if position.y < bottomFifth {
            accelerateToGround(from: position)
        } else {
            simulateSkydiving(from: position)
        }
    }
    
    func accelerateToGround(from position: CGPoint) {
        let fallAction = SKAction.moveTo(y: 0, duration: 0.5)
        skydiver?.run(fallAction)
    }
    
    func flyChaotically(from position: CGPoint) {
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1)
        let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 1)
        let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 1)
        let sequence = SKAction.sequence([moveUp, moveLeft, moveUp, moveRight])
        let repeatAction = SKAction.repeat(sequence, count: 2)
        skydiver?.run(repeatAction)
    }
    
    func countCloudsPassed(through position: CGPoint) -> Int {
        let cloudsPassed = self.children.filter { node in
            guard let cloud = node as? SKSpriteNode, cloud.name == "cloud" else { return false }
            return position.y > cloud.position.y && abs(cloud.position.x - position.x) < cloud.size.width / 2
        }
        return cloudsPassed.count
    }
    
    func simulateSkydiving(from position: CGPoint) {
        guard let skydiver = skydiver else { return }
        
        // 计算穿过的云层数
        let cloudsPassedCount = self.children.filter { node in
            guard let cloud = node as? SKSpriteNode, cloud.name == "cloud" else { return false }
            return position.y > cloud.position.y && abs(cloud.position.x - position.x) < cloud.size.width / 2
        }.count
        skydiver.physicsBody?.isDynamic = false
        
        let groundLevel: CGFloat = bottomBoundary
        let totalFallDistance = position.y - groundLevel
        
        // 加速下降阶段
        let accelerateFallDistance = totalFallDistance * 0.5
        let accelerateAction = SKAction.moveBy(x: 0, y: -accelerateFallDistance, duration: 1)
        
        // 匀速下降阶段
        let normalFallDistance = totalFallDistance * 0.3
        let normalFallAction = SKAction.moveBy(x: 0, y: -normalFallDistance, duration: 2)
        
        // 开伞动作，根据穿过云层数量决定是否开伞
        let sequence: SKAction
        if cloudsPassedCount >= 1 {
            // 如果穿过2个以上的云层，模拟开伞失败，直接进入自由落体
            let freeFallDistance = totalFallDistance - accelerateFallDistance - normalFallDistance
            let freeFallAction = SKAction.moveBy(x: 0, y: -freeFallDistance, duration: 0.5)
            
            sequence = SKAction.sequence([
                accelerateAction,
                normalFallAction,
                freeFallAction,
                SKAction.run { [weak self] in
                    self?.skydiverLanded()
                }
            ])
        } else {
            // 正常开伞过程
            let riseDistance: CGFloat = 55
            let parachuteOpenAction = SKAction.moveBy(x: 0, y: riseDistance, duration: 0.5)
            let finalDescentDistance = totalFallDistance - accelerateFallDistance - normalFallDistance - riseDistance
            let slowDescentAction = SKAction.moveBy(x: 0, y: -(finalDescentDistance + riseDistance), duration: 3.5)
            
            sequence = SKAction.sequence([
                accelerateAction,
                normalFallAction,
                parachuteOpenAction,
                slowDescentAction,
                SKAction.run { [weak self] in
                    self?.skydiverLanded()
                }
            ])
        }
        skydiver.run(sequence)
    }

    func addCloud(at position: CGPoint) {
            // 使用SKSpriteNode加载云朵图片
            let cloud = SKSpriteNode(imageNamed: "cloud")
            cloud.size = CGSize(width: 196, height: 122)
            cloud.position = position
            cloud.name = "cloud"
            addChild(cloud)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let skydiver = skydiver else { return }
        // Check if skydiver has stopped or gone out of bounds
        if gameEnded || skydiver.position.y > size.height || skydiver.position.y < 0 {
            skydiverLanded()
        }
    }
    func skydiverLanded() {
        // Handle game ending logic here
        print("Skydiver end")
        self.selection?.value = 8
    }
}

struct PhaseFourView: View {
    let aspectRatio: CGFloat = 3.0 / 4.0
    let minPadding: CGFloat = 50.0
    let cornerRadius: CGFloat = 32.0
    @EnvironmentObject var selection: Selection
    @State private var scene: PhaseFourScene? = nil
    @State private var resetTrigger = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("background_5")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)

                if let scene = scene {
                    SpriteView(scene: scene)
                        .frame(
                            width: min(geometry.size.width - minPadding * 2, (geometry.size.height - minPadding * 2) * aspectRatio),
                            height: min((geometry.size.width - minPadding * 2) / aspectRatio, geometry.size.height - minPadding * 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .padding(minPadding)
                        .id(resetTrigger)
                }
                // 条件展示 EndView
                if selection.value == 8 {
                    EndView().environmentObject(selection)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // 首次加载时设置场景
            self.scene = self.setupScene()
        }
        .onChange(of: selection.value) { newValue in
            // 监听selection.value的变化，当游戏需要重新开始时重置场景
            if newValue == 4 { // 假设4是游戏重新开始的状态
                self.resetGame()
            }
        }
    }

    private func setupScene() -> PhaseFourScene {
        let newScene = PhaseFourScene()
        newScene.size = CGSize(width: 900, height: 1200)
        newScene.scaleMode = .aspectFit
        newScene.selection = selection
        return newScene
    }
    private func resetGame() {
            self.scene = self.setupScene()
            // 修改状态变量以触发视图重绘
            self.resetTrigger.toggle()
        }
}
