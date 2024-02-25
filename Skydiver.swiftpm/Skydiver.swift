import SpriteKit

class Skydiver: SKSpriteNode {
    
    private var textures: [SKTexture] = []
    private var animation: SKAction?
    private var currentState: SkydiverState = .falling // 初始状态
    
    enum SkydiverState: Int {
        case falling = 1, panic, parachute, landing, crash
    }
    
    init() {
        let texture = SKTexture(imageNamed: "state1_frame1") // 初始纹理
        super.init(texture: texture, color: .clear, size: texture.size())
        
        loadTextures()
        setupAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadTextures() {
        // 加载每个状态的纹理
        for state in 1...5 {
            var stateTextures: [SKTexture] = []
            for frame in 1...3 {
                let texture = SKTexture(imageNamed: "state\(state)_frame\(frame)")
                stateTextures.append(texture)
            }
            textures.append(contentsOf: stateTextures)
        }
    }
    
    private func setupAnimation() {
        // 创建一个动画序列
        let animation = SKAction.animate(with: textures, timePerFrame: 0.1)
        self.animation = SKAction.repeatForever(animation)
    }
    
    func changeState(to state: SkydiverState) {
        // 根据状态更改动画
        removeAllActions()
        switch state {
        case .falling, .panic, .parachute, .landing, .crash:
            // 设置对应状态的动画
            run(animation!, withKey: "animation")
        }
    }
    
    func simulateSkydiving() {
        // 模拟skydiving的状态变化，例如在一段时间后更改状态
        let delay = SKAction.wait(forDuration: 5.0)
        let changeStateAction = SKAction.run {
            // 随机更改状态
            let randomState = Int.random(in: 1...5)
            self.changeState(to: SkydiverState(rawValue: randomState)!)
        }
        let sequence = SKAction.sequence([delay, changeStateAction])
        run(SKAction.repeatForever(sequence))
    }
}
