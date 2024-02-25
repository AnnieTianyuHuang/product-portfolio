import SwiftUI
import SpriteKit

// PhaseTwoScene 类
class PhaseTwoScene: SKScene {
    private var skydiver: SKShapeNode?
    private var placeButton: SKSpriteNode!
    private var canPlaceSkydiver = false
    private var gameEnded = false
    var selection: Selection?

    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupPlaceButton()
        addGreyOutZones()
        gameEnded = false
    }

    private func setupPlaceButton() {
        placeButton = SKSpriteNode(color: .cyan, size: CGSize(width: 150, height: 40))
        placeButton.position = CGPoint(x: frame.midX, y: frame.maxY - 60) // 放置在顶部区域
        placeButton.name = "placeButton"

        let label = SKLabelNode(text: "Tap to Place Skydiver")
        label.fontSize = 24
        label.fontColor = SKColor.black
        label.position = CGPoint.zero
        placeButton.addChild(label)

        addChild(placeButton)
    }

    func addGreyOutZones() {
        // 顶部 1/5 区域保持为白色，不需要添加灰色遮罩
        // 计算灰色区域的高度，即屏幕总高度减去顶部 1/5 区域的高度
        let greyZoneHeight = self.size.height * 4 / 5
        // 灰色区域的大小，覆盖剩余 4/5 的屏幕
        let greyZoneSize = CGSize(width: self.size.width, height: greyZoneHeight)
        
        // 创建一个灰色遮罩覆盖屏幕的底部 4/5
        let greyZone = SKSpriteNode(color: .gray, size: greyZoneSize)
        // 将灰色遮罩的中心点定位到屏幕底部 4/5 区域的中心
        greyZone.position = CGPoint(x: self.size.width / 2, y: greyZoneHeight / 2)
        greyZone.alpha = 0.5 // 设置透明度以便底层内容部分可见
        addChild(greyZone)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        if nodes.contains(where: { $0.name == "placeButton" }) {
            canPlaceSkydiver.toggle()
            placeButton.isHidden = true
            return
        }

        if canPlaceSkydiver {
            let topAllowedZoneHeight = size.height * 4 / 5
            if location.y > topAllowedZoneHeight {
                addSkydiver(at: location)
            }
        }
    }

    private func addSkydiver(at position: CGPoint) {
        skydiver?.removeFromParent()

        skydiver = SKShapeNode(circleOfRadius: 10)
        skydiver?.fillColor = SKColor.blue
        skydiver?.position = position
        skydiver?.name = "skydiver"

        if let skydiverNode = skydiver {
            addChild(skydiverNode)
            flyChaotically(from: position)
        }
    }

    func flyChaotically(from position: CGPoint) {
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1)
        let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 1)
        let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 1)
        let sequence = SKAction.sequence([moveUp, moveLeft, moveUp, moveRight])
        let repeatAction = SKAction.repeat(sequence, count: 2)
        
        skydiver?.run(repeatAction) { [weak self] in
            self?.skydiverLanded()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 只有在游戏进行中时才检查
        if let skydiver = skydiver, !gameEnded {
            // 检查 skydiver 是否超出屏幕顶部
            if skydiver.position.y > self.size.height {
                // 调用游戏结束逻辑
                gameEnded = true
                skydiverLanded()
            }
        }
    }
    
    func skydiverLanded() {
        // This function can be used to handle what happens after the skydiver's action is completed
        self.selection?.value = 6
        print("Skydiver has been dragged to outer space")
    }
}

// SwiftUI View for Phase Two
struct PhaseTwoView: View {
    let aspectRatio: CGFloat = 3.0 / 4.0
    let minPadding: CGFloat = 50.0
    let cornerRadius: CGFloat = 32.0
    @EnvironmentObject var selection: Selection

    var scene: SKScene {
        let scene = PhaseTwoScene()
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

                SpriteView(scene: scene)
                    .frame(
                        width: min(geometry.size.width - minPadding * 2, (geometry.size.height - minPadding * 2) * aspectRatio),
                        height: min((geometry.size.width - minPadding * 2) / aspectRatio, geometry.size.height - minPadding * 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .padding(minPadding)
                if selection.value == 6{ // 这里替换为触发显示 Change1View 的特定值
                    Change2View().environmentObject(selection)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
