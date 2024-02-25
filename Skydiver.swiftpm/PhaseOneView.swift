import SwiftUI
import SpriteKit
class SkyDivingScene: SKScene {
    private var skydiver: SKShapeNode?
    private var placeButton: SKShapeNode!
    private var canPlaceSkydiver = false
    var selection: Selection?
    var backgroundImage = SKSpriteNode(imageNamed: "simulator_mid_enabled")
    private var statusBubble: SKSpriteNode!
    private var statusLabel: SKLabelNode!
    let topBoundary: CGFloat = 20
    let bottomBoundary: CGFloat = 50
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setBackgroundImage(name: "simulator_mid_enabled")
        setupPlaceButton()
    }
    
    func updateStatus(_ status: String) {
        // 更新状态标签的文本
        statusLabel.text = status
        
        // 更新statusBubble纹理，播放对应状态的动画
        let textures = [SKTexture(imageNamed: "\(status)1"),
                        SKTexture(imageNamed: "\(status)2"),
                        SKTexture(imageNamed: "\(status)3")]
        let animationAction = SKAction.animate(with: textures, timePerFrame: 0.3)
        let repeatAction = SKAction.repeatForever(animationAction)
        statusBubble.run(repeatAction)
    }
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let skydiverPosition = skydiver?.position {
            // 设置气泡窗的位置为跳伞者的右上方
            let bubbleOffsetX: CGFloat = 30 // X轴偏移量，可根据需要调整
            let bubbleOffsetY: CGFloat = 30 // Y轴偏移量，可根据需要调整
            statusBubble.position = CGPoint(x: skydiverPosition.x + bubbleOffsetX, y: skydiverPosition.y + bubbleOffsetY)
        }
    }
    private func setupPlaceButton() {
        let buttonSize = CGSize(width: 630, height: 110)
        let cornerRadius: CGFloat = 100
        let backgroundColor = SKColor.black.withAlphaComponent(0.3)
        let buttonRect = CGRect(origin: CGPoint(x: -buttonSize.width / 2, y: -buttonSize.height / 2), size: buttonSize)
        let buttonPath = UIBezierPath(roundedRect: buttonRect, cornerRadius: cornerRadius)
        
        placeButton = SKShapeNode(path: buttonPath.cgPath)
        placeButton.fillColor = backgroundColor
        placeButton.position = CGPoint(x: frame.midX, y: frame.midY)
        placeButton.name = "placeButton"
        let label = SKLabelNode()
        label.text = "Tap to Place Skydiver"
        label.fontSize = 64
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        
        // Create attributed string with desired font weight
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: label.fontSize, weight: .light),
            .foregroundColor: SKColor.white
        ]
        let attributedText = NSAttributedString(string: "Tap to Place Skydiver", attributes: attributes)
        
        // Apply attributed string to label
        label.attributedText = attributedText
        
        placeButton.addChild(label)
        addChild(placeButton)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        if nodes.contains(where: { $0.name == "placeButton" }) {
            canPlaceSkydiver.toggle()
            placeButton.isHidden = true // Hide the button after it's tapped
            return
        }
        if canPlaceSkydiver {
            let middleFifthTop = size.height * 4 / 5
            let middleFifthBottom = size.height * 1 / 5
            if location.y < middleFifthTop && location.y > middleFifthBottom {
                addSkydiver(at: location)
                setBackgroundImage(name: "simulator")
            }
        }
    }
    
    private func setBackgroundImage(name: String) {
        // Remove old background image if exists
        backgroundImage.removeFromParent()
        
        // Set new background image
        backgroundImage = SKSpriteNode(imageNamed: name)
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2 + 5)
        backgroundImage.zPosition = -1 // Ensure it's behind everything
        backgroundImage.setScale(1.0/3.0) // Scale down to desired size
        addChild(backgroundImage)
    }
    
    private func addSkydiver(at position: CGPoint) {
        guard position.y > bottomBoundary && position.y < size.height - topBoundary else { return }
        
        skydiver?.removeFromParent()
        skydiver = SKShapeNode(circleOfRadius: 10)
        skydiver?.fillColor = SKColor.blue
        skydiver?.position = position
        skydiver?.name = "skydiver"
        if let skydiverNode = skydiver {
            addChild(skydiverNode)
            simulateSkydiving(from: position)
        }
        
        // 创建并设置气泡窗节点
        statusBubble = SKSpriteNode(imageNamed: "bubbleImage")
        statusBubble.position = CGPoint(x: self.size.width - 150, y: self.size.height - 100) // 示例位置
        self.addChild(statusBubble)
        
        // 创建并设置状态标签
        statusLabel = SKLabelNode(fontNamed: "Arial")
        statusLabel.fontSize = 20
        statusLabel.fontColor = SKColor.black
        statusLabel.position = CGPoint(x: 0, y: -10) // 相对于气泡窗的位置
        statusBubble.addChild(statusLabel)
        
        // 示例：更新状态文本
        updateStatus("Falling")
    }
    
    func simulateSkydiving(from position: CGPoint) {
        guard let skydiver = skydiver else { return }

        // 调整地面水平，考虑到底部边界
        let groundLevel: CGFloat = bottomBoundary
        let totalFallDistance = position.y - groundLevel

        // 加速下降阶段
        let updateAccelerateStatus = SKAction.run { [weak self] in self?.updateStatus("Accelerating") }
        let accelerateFallDistance = totalFallDistance * 0.5
        let accelerateAction = SKAction.moveBy(x: 0, y: -accelerateFallDistance, duration: 1)

        // 正常下降阶段
        let updateNormalFallStatus = SKAction.run { [weak self] in self?.updateStatus("Normal Falling") }
        let normalFallDistance = totalFallDistance * 0.3
        let normalFallAction = SKAction.moveBy(x: 0, y: -normalFallDistance, duration: 2)

        // 降落伞打开阶段
        let updateParachuteOpenStatus = SKAction.run { [weak self] in self?.updateStatus("Parachute Open") }
        let riseDistance: CGFloat = 55
        let parachuteOpenAction = SKAction.moveBy(x: 0, y: riseDistance, duration: 0.5)

        // 缓慢下降阶段，确保下降停止在 groundLevel 之上
        let updateSlowDescentStatus = SKAction.run { [weak self] in self?.updateStatus("Slow Descent") }
        let finalDescentDistance = position.y - groundLevel - accelerateFallDistance - normalFallDistance - riseDistance
        let slowDescentAction = SKAction.moveBy(x: 0, y: -finalDescentDistance, duration: 3.5)

        // 创建动作序列，先更新状态，再执行动作
        let sequence = SKAction.sequence([
            updateAccelerateStatus, accelerateAction,
            updateNormalFallStatus, normalFallAction,
            updateParachuteOpenStatus, parachuteOpenAction,
            updateSlowDescentStatus, slowDescentAction,
            SKAction.run { [weak self] in self?.skydiverLanded() }
        ])
        
        // 运行动作序列
        skydiver.run(sequence)
    }
    
    func skydiverLanded() {
        // 打印信息到控制台，表明跳伞者已经着陆
        print("Skydiver has landed.")
        // 更新你用来表示跳伞者已落地的逻辑
        selection?.value = 5
        
        // 更新状态为着陆，假设有对应的"landed"纹理图片
        let landedTexture = SKTexture(imageNamed: "landed")
        statusBubble.texture = landedTexture
        
        // 如果需要，还可以停止所有正在进行的动画，以反映跳伞者已经停止移动
        statusBubble.removeAllActions()
        
        // 更新状态标签为"Landed"
        updateStatus("Landed")
    }

    
}
// SwiftUI 视图，展示你的 Scene
struct PhaseOneView: View {
    let aspectRatio: CGFloat = 3.0 / 4.0
    let minPadding: CGFloat = 50.0
    let cornerRadius: CGFloat = 32.0
    @EnvironmentObject var selection: Selection
    var scene: SKScene {
        let scene = SkyDivingScene()
        scene.size = CGSize(width: 900, height: 1200)
        scene.scaleMode = .aspectFit
        scene.selection = selection
        return scene
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("background_5")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                Text("Current selection value: \(selection.value)")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .onAppear {
                                    print("PhaseOneView is now showing with selection.value: \(selection.value)")
                                }
                SpriteView(scene: scene)
                    .frame(
                        width: min(geometry.size.width - minPadding * 2, (geometry.size.height - minPadding * 2) * aspectRatio),
                        height: min((geometry.size.width - minPadding * 2) / aspectRatio, geometry.size.height - minPadding * 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .padding(minPadding)
                if selection.value == 5{
                    Change1View().environmentObject(selection)
                }
            }.onAppear {
                print("PhaseOneView is now showing with selection.value: \(selection.value)")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

