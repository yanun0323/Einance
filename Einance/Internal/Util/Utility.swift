import SwiftUI

struct Util {}

extension Util {
    
    /**
     # rgb2hsv
     convert rgb color into hsv color
     - 0 <= r, g, b <= 255
     - 0 <= h < 360
     - 0 <= s, v <= 100
     */
    static func rgb2hsv(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let dR = r/255
        let dG = g/255
        let dB = b/255
        let cMax = max(dR, max(dG, dB))
        let cMin = min(dR, min(dG, dB))
        let delta = cMax - cMin
        
        var h: CGFloat = 0
        switch cMax {
            case 0:
                h = 0
            case dR:
                h = 60*(((dG-dB)/delta).truncatingRemainder(dividingBy: 6))
            case dG:
                h = 60*((dB-dR)/delta + 2)
            case dB:
                h = 60*((dR-dG)/delta + 4)
            default:
                h = 0
        }
        if delta == 0 { h = 0 }
        let s: CGFloat = cMax == 0 ? 0 : 100 * (delta/cMax)
        let v = 100 * cMax
        
        while h < 0 {
            h += 360
        }
        
        while h > 360 {
            h -= 360
        }
        
        return (h, s, v)
    }
    
    /**
     # hsv2rgb
     convert hsv color into rgb color
     - 0 <= h < 360
     - 0 <= s, v <= 1
     - 0 <= r, g, b <= 255
     */
    static func hsv2rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let c = v * s
        let x = c * (1 - abs((h/60).truncatingRemainder(dividingBy: 2)-1))
        let m = v - c
        
        let d = calRGB(h: h, x: x, c: c)
        
        return ((d.r+m)*255, (d.g+m)*255, (d.b+m)*255)
    }
    
    static private func calRGB(h: CGFloat, x: CGFloat, c: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        if h < 0 {  return (0, 0, 0) }
        if h < 60 { return (c, x ,0) }
        if h < 120 { return (x, c, 0) }
        if h < 180 { return (0, c, x) }
        if h < 240 { return (0, x, c) }
        if h < 300 { return (x, 0, c) }
        if h < 360 { return (c, 0, x) }
        return (0, 0, 0)
    }
}
