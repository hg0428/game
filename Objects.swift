//
//  Objects.swift
//  game
//
//  Created by BlobKat on 22/07/2021.
//

import Foundation
import SpriteKit

let G: CGFloat = 0.0001
struct bitmask{
    static let ship: UInt32 = 1
    static let planet: UInt32 = 2
    static let asteroid: UInt32 = 4
}

class Ship: SKSpriteNode{
    var radius: CGFloat = 0
    var mass: CGFloat = 1
    var velocity: CGVector = CGVector()
    var angularVelocity: CGFloat = 0
    var particleOffset: Int = 0
    var producesParticles: Bool = false
    init(radius: CGFloat, mass: CGFloat = -1, texture: SKTexture = SKTexture()){
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.body(radius: radius, mass: mass)
    }
    func update(){
        let parent = self.parent as? Play
        
        position.x += velocity.dx
        position.y += velocity.dy
        zRotation += angularVelocity
        guard producesParticles else {particleOffset=0;return}
        particleOffset = (particleOffset + 1) % 7
        guard particleOffset == 0 else {return}
        parent?.particles.append(Particle(type: "fire", position: position, velocity: CGVector(dx: velocity.dx + sin(zRotation) / 2, dy: velocity.dy - cos(zRotation) / 2), texture: SKTexture(imageNamed: "trail"), color: UIColor.yellow, size: CGSize(width: 10, height: 10), alpha: 0.9, decayRate: 0.01, spin: 0.05))
        if parent != nil{
            parent!.addChild(parent!.particles.last!)
        }
    }
    func body(radius: CGFloat, mass: CGFloat, texture: SKTexture? = nil){
        var m = mass
        if m == -1{
            m = radius * radius
        }
        self.mass = m
        self.radius = radius
        if let t = texture{
            self.texture = t
            self.size = t.size()
        }
        self.setScale(0.25)
    }
    
    convenience init(){
        self.init(radius: 0, mass: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class Planet: Ship{
    override func update(){
        zRotation += angularVelocity
    }
    func gravity(_ n: Ship) -> Bool{
        let mass: CGFloat = self.mass
        let x = n.position.x - self.position.x
        let y = n.position.y - self.position.y
        let d = (x * x + y * y)
        var r = self.radius * self.radius - n.radius * n.radius
        r += (2 * sqrt(r) + n.radius) * n.radius
        if d < r - 1{
            //collided
            let m = sqrt(r / d) - 1
            n.position.x += x * m
            n.position.y += y * m
            n.velocity.dx = 0
            n.velocity.dy = 0
            n.angularVelocity = 0
            n.zRotation = atan2(y, x) - .pi/2
            return true
        }else if d < r{
            //resting on planet
            return true
        }else{
            let m = -(mass*G)/d
            n.velocity.dx += x * m
            n.velocity.dy += y * m
        }
        return false
    }
}
class Ray{
    var position: CGPoint
    var direction: CGFloat
    init(position: CGPoint, direction: CGFloat){
        self.position = position
        self.direction = direction
    }
    func intersects(_ n: Ship) -> Bool{
        let x = n.position.x - self.position.x
        let y = n.position.y - self.position.y
        let ang = atan2(y, x)
        let width = atan(n.radius / sqrt(x*x + y*y))
        let a = abs(ang - self.direction)
        return a < width || a > .pi*2 - width
    }
}
class Particle: SKSpriteNode{
    var velocity: CGVector
    var type: String
    var decayRate: CGFloat
    var spin: CGFloat
    init(type: String, position: CGPoint, velocity: CGVector, texture: SKTexture, color: UIColor, size: CGSize, alpha: CGFloat, decayRate: CGFloat, spin: CGFloat){
        self.type = type
        self.velocity = velocity
        self.decayRate = decayRate
        self.spin = spin
        super.init(texture: SKTexture(), color: color, size: size)
        self.alpha = alpha
        self.position = position
        self.texture = nil
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func update(){
        self.position.x += velocity.dx
        self.position.y += velocity.dy
        self.alpha -= decayRate
        self.zRotation += spin
        
        var red = CGFloat()
        var green = CGFloat()
        var blue = CGFloat()
        self.color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        self.color = UIColor(red: red, green: green - 0.01, blue: blue, alpha: 1)
    }
}
