/**
    A loading bar that indicates ongoing activity.

    progress = 0.5 // updated progress
        Loading Item [===    ] 50%

    fail()
        Loading Item [Failed]

    finish()
        Loading Item [Done]
*/
public class ProgressBar: Bar {
    public var progress: Double {
        didSet {
            #if !Simple
            update()
            #endif
        }
    }

    override init(console: Console, title: String, width: Int, barStyle: ConsoleStyle, titleStyle: ConsoleStyle) {
        progress = 0
        super.init(console: console, title: title, width: width, barStyle: barStyle, titleStyle: titleStyle)
    }

    public override func update() {
        super.update()
    }

    override var bar: String {
        let result: Double = progress * Double(width)
        if result.isNaN || result.isInfinite {
            return "[ NaN or Infinite Value ]"
        }

        let current = Int(result)

        var string: String = "["

        for i in 0 ..< width {
            if i <= current {
                string += "="
            } else {
                string += " "
            }
        }

        string += "]"

        return string
    }

    override var status: String {
        let result: Double = progress * 100.0
        if result.isNaN || result.isInfinite {
            return ""
        }

        let percent = Int(result)
        return " \(percent)%"
    }

}
