//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

//Context?
//cgColor v UIColor
//UIBezierPath
//gradient / fill
//stroke



class Graph : UIView {
    var data : [Float]?
    var graphStart : Float?
    var graphEnd : Float?
    
    var lineColor : UIColor?
    var graphBackgroundColor : UIColor?
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let startColor = graphBackgroundColor?.cgColor
        let endColor = graphBackgroundColor?.withAlphaComponent(0.5).cgColor
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: [startColor, endColor] as CFArray, locations: [0.0, 1.0]) else { return }
        
        let roundedOutlinePath = UIBezierPath(roundedRect: rect.insetBy(dx: 0.015 * rect.width, dy: 0.015 * rect.width), cornerRadius: rect.size.width * 0.1)
        
        context.saveGState()
        roundedOutlinePath.addClip()
        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: rect.height + rect.origin.y), options: [])
        context.restoreGState()
        
//        graphBackgroundColor?.setFill()
//        roundedOutlinePath.fill()

        let outlineRect = rect.insetBy(dx: rect.width * 0.075, dy: rect.width * 0.075)
        let graphRect = outlineRect.insetBy(dx: rect.width * 0.05, dy: rect.width * 0.05)
        
        if let lc = lineColor {
  
            let outline = UIBezierPath(rect: outlineRect)
            lc.setStroke()
            outline.stroke()
            
            let dottedLine = UIBezierPath()
            dottedLine.move(to: CGPoint(x: graphRect.origin.x, y: graphRect.origin.y + graphRect.size.height / 2.0))
            dottedLine.addLine(to: CGPoint(x: graphRect.origin.x + graphRect.size.width, y: graphRect.origin.y + graphRect.size.height / 2.0))
            dottedLine.setLineDash([5.0, 5.0], count: 2, phase: 0.0)
            
            dottedLine.stroke()
        }
        
        
        if let d = data,
            let start = graphStart,
            let end = graphEnd,
            let lc = lineColor {
      
            let graphGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor.white.withAlphaComponent(0.4).cgColor, UIColor.clear.cgColor] as CFArray, locations: [0.0, 1.0])
            
            
            let graphLine = generatePathForPoints(end: end, start: start, points: d, inRect: graphRect)
            lc.setStroke()
            graphLine.stroke()
            
            drawGradientUnderPath(path: graphLine, inRect: graphRect, gradient: graphGradient!, context: context)
            
            drawNumbers(count: d.count, inRect: graphRect.offsetBy(dx: 0.0, dy: 172.0))
        }
    }
    
    func generatePathForPoints(end : Float, start : Float, points : [Float], inRect : CGRect) -> UIBezierPath {
        let graphHeight = Float(inRect.size.height)
        let distanceBetweenPoints = Float(inRect.size.width) / Float(points.count - 1)
        let firstPointHeight = graphHeight - ((points[0] - start) / (end - start)) * graphHeight
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: inRect.origin.x, y: inRect.origin.y + CGFloat(firstPointHeight)))
        
        for i in 1..<points.count {
            let nextPointHeight = graphHeight - ((points[i] - start) / (end - start)) * graphHeight
            let nextPointXCoord = Float(i) * distanceBetweenPoints
            
            let nextPoint = CGPoint(x: CGFloat(nextPointXCoord) + inRect.origin.x, y: CGFloat(nextPointHeight) + inRect.origin.y)
            
            linePath.addLine(to: nextPoint)
        }
        
        return linePath
    }
    
    func drawGradientUnderPath(path : UIBezierPath, inRect: CGRect, gradient : CGGradient, context : CGContext) {
        path.addLine(to: CGPoint(x: inRect.origin.x + inRect.size.width, y: inRect.origin.y + inRect.size.height))
        path.addLine(to: CGPoint(x: inRect.origin.x, y: inRect.origin.y + inRect.size.height))
        path.close()
        
        context.saveGState()
        path.addClip()
        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: inRect.origin.y), end: CGPoint(x:0.0, y: inRect.origin.y + inRect.size.height), options: [])
        context.restoreGState()
    }
    
    func drawNumbers(count : Int, inRect : CGRect) {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.labelFontSize), NSForegroundColorAttributeName: UIColor.white]
        let width = CGFloat(inRect.width) / CGFloat(count - 1)
        for i in 0..<count {
            let string = NSAttributedString(string: "\(i + 1)", attributes: attributes)
            string.draw(at: CGPoint(x: inRect.origin.x - 7.0 + CGFloat(i) * width, y: inRect.origin.y))
        }
    }
}

let graph = Graph(frame: CGRect(x: 0, y: 0, width: 400, height: 250))
graph.backgroundColor = UIColor.clear
graph.lineColor = UIColor.white
graph.graphBackgroundColor = UIColor.lightGray
graph.data = [0.7, 0.3, 0.5, 0.3, 0.4, 0.6, 0.7, 0.0, 0.5, 0.4, 0.35, 0.6, 0.3, 0.25, 0.12]
graph.graphStart = 0.0
graph.graphEnd = 0.7

PlaygroundPage.current.liveView = graph
graph.setNeedsDisplay()