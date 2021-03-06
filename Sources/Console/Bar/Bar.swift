import libc

public class Bar {
    let console: Console
    let title: String
    let width: Int
    let barStyle: ConsoleStyle
    let titleStyle: ConsoleStyle

    var hasStarted: Bool
    var hasFinished: Bool

    var mutex: UnsafeMutablePointer<pthread_mutex_t>

    public init(console: Console, title: String, width: Int, barStyle: ConsoleStyle, titleStyle: ConsoleStyle) {
        self.console = console
        self.width = width
        self.title = title
        self.barStyle = barStyle
        self.titleStyle = titleStyle

        hasStarted = false
        hasFinished = false

        mutex = UnsafeMutablePointer(allocatingCapacity: 1)
        pthread_mutex_init(mutex, nil)
    }

    deinit {
        mutex.deinitialize()
        mutex.deallocateCapacity(1)
    }

    public func fail(_ message: String? = nil) {
        let message = message ?? "Failed"

        collapseBar(message: message, style: .error)
    }

    public func finish(_ message: String? = nil) {
        guard !hasFinished else {
            return
        }
        hasFinished = true

        let message = message ?? "Done"

        #if Simple
            prepareLine()
            console.output(title, style: titleStyle, newLine: false)
            console.output(" [\(message)]", style: .success)
        #else
            collapseBar(message: message, style: .success)
        #endif
    }

    func collapseBar(message: String, style: ConsoleStyle) {
        pthread_mutex_lock(mutex)
        for i in 0 ..< (width - message.characters.count) {
            prepareLine()

            console.output(title, style: titleStyle, newLine: false)

            let rate = (width - message.characters.count) / message.characters.count
            let charactersShowing = i / rate


            var newBar: String = " ["
            for j in 0 ..< charactersShowing {
                let index = message.characters.index(message.characters.startIndex, offsetBy: j)
                newBar.append(message.characters[index])
            }
            console.output(newBar, style: style, newLine: false)

            var oldBar = ""
            for _ in 0 ..< (width - i - 1 - charactersShowing) {
                let index = bar.characters.index(bar.characters.endIndex, offsetBy: -2)
                oldBar.append(bar.characters[index])
            }
            oldBar.append("]")

            console.output(oldBar, style: barStyle, newLine: true)

            console.wait(seconds: 0.01)
        }

        prepareLine()
        console.output(title, style: titleStyle, newLine: false)
        console.output(" [\(message)]", style: style)
        pthread_mutex_unlock(mutex)
    }

    public func update() {
        pthread_mutex_lock(mutex)
        prepareLine()

        console.output(title + " ", style: titleStyle, newLine: false)
        console.output(bar, style: barStyle, newLine: false)
        console.output(status, style: titleStyle)
        pthread_mutex_unlock(mutex)
    }

    public func prepareLine() {
        if hasStarted {
            console.clear(.line)
        } else {
            hasStarted = true
        }
    }
    
    var bar: String {
        return ""
    }
    
    var status: String {
        return ""
    }
}
