import SwiftUI
import SpriteKit

// PhaseThreeScene 类
class PhaseThreeScene: SKScene {
    private var skydiver: SKShapeNode?
    private var placeButton: SKSpriteNode!
    private var canPlaceSkydiver = false
    private var gameEnded = false
    var selection: Selection?

    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        self.scaleMode = .resizeFill
        setupPlaceButton()
        addGreyOutZones()
    }

    private func setupPlaceButton() {
        // 初始化放置按钮
        placeButton = SKSpriteNode(color: .cyan, size: CGSize(width: 150, height: 40))
        placeButton.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 60) // 放置在底部区域
        placeButton.name = "placeButton"

        let label = SKLabelNode(text: "Tap to Place Skydiver")
        label.fontSize = 20
        label.fontColor = SKColor.black
        label.position = CGPoint.zero
        placeButton.addChild(label)

        self.addChild(placeButton)
    }

    func addGreyOutZones() {
        // 底部 1/5 区域是允许放置 skydiver 的区域，其余区域灰色遮罩
        let allowedZoneHeight = self.size.height / 5
        let greyZoneHeight = self.size.height - allowedZoneHeight
        let greyZone = SKSpriteNode(color: .gray, size: CGSize(width: self.size.width, height: greyZoneHeight))
        greyZone.position = CGPoint(x: self.size.width / 2, y: self.size.height - greyZoneHeight / 2)
        greyZone.alpha = 0.5
        self.addChild(greyZone)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        if nodes.contains(where: { $0.name == "placeButton" }) {
            // 切换放置 skydiver 的能力
            canPlaceSkydiver.toggle()
            placeButton.isHidden = true // 点击后隐藏按钮
            return
        }

        if canPlaceSkydiver && location.y <= self.size.height / 4 {
            // 只在底部 1/5 区域放置 skydiver
            addSkydiver(at: location)
        }
    }

    private func addSkydiver(at position: CGPoint) {
        // 移除旧的 skydiver，如果存在
        skydiver?.removeFromParent()

        // 创建新的 skydiver
        skydiver = SKShapeNode(circleOfRadius: 10)
        skydiver?.fillColor = SKColor.blue
        skydiver?.position = position
        skydiver?.name = "skydiver"

        if let skydiverNode = skydiver {
            self.addChild(skydiverNode)
            accelerateToGround(from: position)
        }
    }

    func accelerateToGround(from position: CGPoint) {
        // 计算目标Y位置，留有20单位的空间
        let targetY = 30.0 // 假设屏幕底部坐标为0
        let duration = 0.5 // 可以根据需要调整持续时间来模拟加速效果

        // 创建移动动作，将小球移动到距离屏幕底部20单位的位置
        let fallAction = SKAction.moveTo(y: targetY, duration: duration)
        
        // 运行动作
        skydiver?.run(fallAction) { [weak self] in
            self?.gameEnded = true
            self?.selection?.value = 7
        }
    }




    override func update(_ currentTime: TimeInterval) {
        // 游戏进行中时的逻辑
        if let skydiver = skydiver, !gameEnded {
            // 如果小球接近停止位置，则结束游戏
            if skydiver.position.y <= 20 + skydiver.frame.size.height / 2 {
                skydiver.removeAllActions() // 停止所有动作
                skydiver.position.y = 20 + skydiver.frame.size.height / 2 // 确保小球在正确的停止位置
                gameEnded = true
                skydiverLanded() // 调用降落后的处理函数
            }
        }
    }



    func skydiverLanded() {
        // 处理 skydiver 降落后的逻辑
        self.selection?.value = 7
        print("Skydiver has landed.")
    }
}


// SwiftUI View for Phase Two
struct PhaseThreeView: View {
    let aspectRatio: CGFloat = 3.0 / 4.0
    let minPadding: CGFloat = 50.0
    let cornerRadius: CGFloat = 32.0
    @EnvironmentObject var selection: Selection

    var scene: SKScene {
        let scene = PhaseThreeScene()
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
                if selection.value == 7{ // 这里替换为触发显示 Change1View 的特定值
                    Change3View().environmentObject(selection)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

