import Cocoa

// MARK: - Window

final class WelcomeWindowController: NSObject, NSWindowDelegate {
    static let shared = WelcomeWindowController()

    private var window: NSWindow?

    func showWindow() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1_020, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Amar Avro Keyboard"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.minSize = NSSize(width: 940, height: 660)
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.delegate = self
        window.contentView = DashboardView()
        window.center()

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Dashboard shell

private final class DashboardView: NSView {
    private let contentHost = NSView()
    private var pages: [NSView] = []
    private var navigationButtons: [NavigationButton] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        buildInterface()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildInterface() {
        let backdrop = DashboardBackgroundView()
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backdrop)

        let sidebar = makeSidebar()
        sidebar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sidebar)

        contentHost.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentHost)

        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdrop.bottomAnchor.constraint(equalTo: bottomAnchor),

            sidebar.topAnchor.constraint(equalTo: topAnchor),
            sidebar.leadingAnchor.constraint(equalTo: leadingAnchor),
            sidebar.bottomAnchor.constraint(equalTo: bottomAnchor),
            sidebar.widthAnchor.constraint(equalToConstant: 252),

            contentHost.topAnchor.constraint(equalTo: topAnchor),
            contentHost.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor),
            contentHost.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentHost.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        pages = [HomePage(), TypingModesPage(), LayoutGuidePage(), AboutPage()]
        for page in pages {
            page.translatesAutoresizingMaskIntoConstraints = false
            contentHost.addSubview(page)
            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: contentHost.topAnchor, constant: 42),
                page.leadingAnchor.constraint(equalTo: contentHost.leadingAnchor, constant: 38),
                page.trailingAnchor.constraint(equalTo: contentHost.trailingAnchor, constant: -38),
                page.bottomAnchor.constraint(equalTo: contentHost.bottomAnchor, constant: -30),
            ])
        }
        showPage(at: 0)
    }

    private func makeSidebar() -> NSVisualEffectView {
        let sidebar = NSVisualEffectView()
        sidebar.material = .sidebar
        sidebar.blendingMode = .behindWindow
        sidebar.state = .active

        let logo = NSImageView()
        logo.image = Brand.appIcon
        logo.imageScaling = .scaleProportionallyUpOrDown
        logo.translatesAutoresizingMaskIntoConstraints = false

        let title = UI.label("Amar Avro", size: 21, weight: .bold)
        let keyboard = UI.label("KEYBOARD", size: 10, weight: .semibold, color: .secondaryLabelColor)
        keyboard.attributedStringValue = NSAttributedString(
            string: "K E Y B O A R D",
            attributes: [
                .font: NSFont.systemFont(ofSize: 9.5, weight: .semibold),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
        )

        let brandStack = NSStackView(views: [logo, title, keyboard])
        brandStack.orientation = .vertical
        brandStack.alignment = .centerX
        brandStack.spacing = 5
        brandStack.translatesAutoresizingMaskIntoConstraints = false

        let navigation = NSStackView()
        navigation.orientation = .vertical
        navigation.alignment = .leading
        navigation.spacing = 7
        navigation.translatesAutoresizingMaskIntoConstraints = false

        let items = [
            ("Home", "house.fill"),
            ("Typing Modes", "slider.horizontal.3"),
            ("Layout Guide", "keyboard"),
            ("About", "info.circle.fill"),
        ]
        for (index, item) in items.enumerated() {
            let button = NavigationButton(title: item.0, symbol: item.1)
            button.tag = index
            button.target = self
            button.action = #selector(navigationPressed(_:))
            navigation.addArrangedSubview(button)
            button.widthAnchor.constraint(equalTo: navigation.widthAnchor).isActive = true
            navigationButtons.append(button)
        }

        let developer = UI.label("Developed by", size: 10, weight: .medium, color: .tertiaryLabelColor)
        let developerName = UI.label("Md Rakib Hossain", size: 12, weight: .semibold)
        let footer = NSStackView(views: [developer, developerName])
        footer.orientation = .vertical
        footer.alignment = .leading
        footer.spacing = 3
        footer.translatesAutoresizingMaskIntoConstraints = false

        sidebar.addSubview(brandStack)
        sidebar.addSubview(navigation)
        sidebar.addSubview(footer)

        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 88),
            logo.heightAnchor.constraint(equalToConstant: 88),
            brandStack.topAnchor.constraint(equalTo: sidebar.topAnchor, constant: 55),
            brandStack.centerXAnchor.constraint(equalTo: sidebar.centerXAnchor),

            navigation.topAnchor.constraint(equalTo: brandStack.bottomAnchor, constant: 40),
            navigation.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 18),
            navigation.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -18),

            footer.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 28),
            footer.bottomAnchor.constraint(equalTo: sidebar.bottomAnchor, constant: -25),
        ])
        return sidebar
    }

    @objc private func navigationPressed(_ sender: NavigationButton) {
        showPage(at: sender.tag)
    }

    private func showPage(at index: Int) {
        for (pageIndex, page) in pages.enumerated() {
            page.isHidden = pageIndex != index
        }
        for (buttonIndex, button) in navigationButtons.enumerated() {
            button.setSelected(buttonIndex == index)
        }
    }
}

private final class NavigationButton: NSButton {
    private let labelText: String

    init(title: String, symbol: String) {
        self.labelText = title
        super.init(frame: .zero)
        self.title = title
        image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
        imagePosition = .imageLeading
        alignment = .left
        isBordered = false
        font = .systemFont(ofSize: 13.5, weight: .medium)
        wantsLayer = true
        layer?.cornerRadius = 11
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 42).isActive = true
        setSelected(false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ selected: Bool) {
        let color: NSColor = selected ? .labelColor : .secondaryLabelColor
        attributedTitle = NSAttributedString(
            string: labelText,
            attributes: [
                .font: NSFont.systemFont(ofSize: 13.5, weight: selected ? .semibold : .medium),
                .foregroundColor: color,
            ]
        )
        contentTintColor = color
        layer?.backgroundColor = selected
            ? NSColor.labelColor.withAlphaComponent(0.08).cgColor
            : NSColor.clear.cgColor
    }
}

private final class DashboardBackgroundView: NSVisualEffectView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        material = .underWindowBackground
        blendingMode = .behindWindow
        state = .active
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Pages

private final class HomePage: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let header = UI.pageHeader(
            title: "Amar Avro Keyboard",
            subtitle: "A private, native phonetic Bangla input method for macOS."
        )

        let heroIcon = NSImageView(image: Brand.appIcon)
        heroIcon.imageScaling = .scaleProportionallyUpOrDown
        heroIcon.translatesAutoresizingMaskIntoConstraints = false
        heroIcon.widthAnchor.constraint(equalToConstant: 92).isActive = true
        heroIcon.heightAnchor.constraint(equalToConstant: 92).isActive = true

        let heroTitle = UI.label("Ready when you are", size: 24, weight: .bold)
        let heroDetail = UI.wrappingLabel(
            "Type naturally with English letters and receive accurate Bangla text in any Mac app. All processing stays on your device.",
            size: 13.5,
            color: .secondaryLabelColor
        )
        let badge = StatusBadge(text: "NATIVE • OFFLINE • UNIVERSAL")
        let heroText = NSStackView(views: [badge, heroTitle, heroDetail])
        heroText.orientation = .vertical
        heroText.alignment = .leading
        heroText.spacing = 8

        let heroRow = NSStackView(views: [heroIcon, heroText])
        heroRow.orientation = .horizontal
        heroRow.alignment = .centerY
        heroRow.spacing = 22
        let hero = CardView(content: heroRow, padding: 22)

        let steps = NSStackView(views: [
            UI.stepRow(number: "1", title: "Add the input source", detail: "Open System Settings → Keyboard → Text Input → Edit, then choose Amar Avro Keyboard under Bengali."),
            UI.divider(),
            UI.stepRow(number: "2", title: "Switch input sources", detail: "Press Control + Space or use the Globe key whenever you want to type in Bangla."),
            UI.divider(),
            UI.stepRow(number: "3", title: "Type phonetically", detail: "For example: ami banglay gan gai → আমি বাংলায় গান গাই"),
        ])
        steps.orientation = .vertical
        steps.spacing = 12
        let setup = CardView(title: "Quick Setup", content: steps)

        let examples = NSStackView(views: [
            UI.exampleChip(input: "amar", output: "আমার"),
            UI.exampleChip(input: "bangla", output: "বাংলা"),
            UI.exampleChip(input: "bhalobasha", output: "ভালোবাসা"),
        ])
        examples.orientation = .horizontal
        examples.distribution = .fillEqually
        examples.spacing = 12
        let preview = CardView(title: "Typing Preview", content: examples)

        let stack = UI.pageStack([header, hero, setup, preview])
        addPinned(stack)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class TypingModesPage: NSView {
    private var buttons: [NSButton] = []
    private let modes: [AmarAvroKeyboardInputController.TypingMode] = [
        .phoneticFirst, .smart, .phoneticOnly,
    ]

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let header = UI.pageHeader(
            title: "Typing Modes",
            subtitle: "Choose the level of assistance that best matches your typing style. Changes apply immediately."
        )

        let choices: [(String, String, String)] = [
            ("Phonetic-first", "Recommended", "Keeps the direct phonetic conversion selected while offering useful alternatives."),
            ("Smart Suggestions", "Adaptive", "Uses the dictionary, autocorrect and your previous selections to prioritize likely results."),
            ("Phonetic-only", "Focused", "Converts keystrokes directly without displaying a candidate window."),
        ]

        var cards: [NSView] = []
        for (index, choice) in choices.enumerated() {
            let radio = NSButton(
                radioButtonWithTitle: choice.0,
                target: self,
                action: #selector(modeChanged(_:))
            )
            radio.tag = index
            radio.font = .systemFont(ofSize: 15, weight: .semibold)
            buttons.append(radio)

            let detail = UI.wrappingLabel(choice.2, size: 12.5, color: .secondaryLabelColor)
            let text = NSStackView(views: [radio, detail])
            text.orientation = .vertical
            text.alignment = .leading
            text.spacing = 7

            let tag = StatusBadge(text: choice.1.uppercased())
            let row = NSStackView(views: [text, tag])
            row.orientation = .horizontal
            row.alignment = .centerY
            row.distribution = .fill
            row.spacing = 16
            tag.setContentHuggingPriority(.required, for: .horizontal)
            cards.append(CardView(content: row, padding: 20))
        }

        let note = UI.wrappingLabel(
            "Phonetic-first is the best starting point for consistent results. You can change this setting at any time.",
            size: 12.5,
            color: .secondaryLabelColor
        )
        let noteCard = CardView(title: "Recommendation", content: note)

        let stack = UI.pageStack([header] + cards + [noteCard])
        addPinned(stack)
        refreshSelection()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func modeChanged(_ sender: NSButton) {
        let mode = modes[sender.tag]
        UserDefaults.standard.set(mode.rawValue, forKey: AmarAvroKeyboardInputController.typingModeKey)
        NotificationCenter.default.post(name: .amarAvroKeyboardTypingModeChanged, object: nil)
        refreshSelection()
    }

    private func refreshSelection() {
        let current = AmarAvroKeyboardInputController.currentTypingMode()
        for (index, button) in buttons.enumerated() {
            button.state = modes[index] == current ? .on : .off
        }
    }
}

private final class LayoutGuidePage: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let header = UI.pageHeader(
            title: "Layout Guide",
            subtitle: "A concise reference for common phonetic combinations and everyday phrases."
        )

        let rows: [[NSView]] = [
            [UI.mapping("a", "আ"), UI.mapping("i", "ই"), UI.mapping("u", "উ")],
            [UI.mapping("k", "ক"), UI.mapping("kh", "খ"), UI.mapping("g", "গ")],
            [UI.mapping("ch", "ছ"), UI.mapping("j", "জ"), UI.mapping("t", "ত")],
            [UI.mapping("th", "থ"), UI.mapping("d", "দ"), UI.mapping("dh", "ধ")],
            [UI.mapping("sh", "শ"), UI.mapping("s", "স"), UI.mapping("h", "হ")],
        ]
        let grid = NSGridView(views: rows)
        grid.rowSpacing = 12
        grid.columnSpacing = 12
        let mappingCard = CardView(title: "Common Keys", content: grid)

        let examples = NSStackView(views: [
            UI.phraseRow("ami", "আমি"),
            UI.divider(),
            UI.phraseRow("apni kemon achhen", "আপনি কেমন আছেন"),
            UI.divider(),
            UI.phraseRow("amar sonar bangla", "আমার সোনার বাংলা"),
            UI.divider(),
            UI.phraseRow("dhonnobad", "ধন্যবাদ"),
        ])
        examples.orientation = .vertical
        examples.spacing = 11
        let examplesCard = CardView(title: "Try These", content: examples)

        let stack = UI.pageStack([header, mappingCard, examplesCard])
        addPinned(stack)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class AboutPage: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let header = UI.pageHeader(
            title: "About",
            subtitle: "A focused Bangla typing experience built specifically for macOS."
        )

        let icon = NSImageView(image: Brand.appIcon)
        icon.imageScaling = .scaleProportionallyUpOrDown
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 128).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 128).isActive = true

        let name = UI.label("Amar Avro Keyboard", size: 26, weight: .bold)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.6.0"
        let versionLabel = UI.label("Version \(version) • Universal macOS", size: 12.5, weight: .medium, color: .secondaryLabelColor)
        let tagline = UI.label("Native • Private • System-wide", size: 14, weight: .semibold, color: .secondaryLabelColor)
        let info = NSStackView(views: [name, versionLabel, tagline])
        info.orientation = .vertical
        info.alignment = .leading
        info.spacing = 8

        let product = NSStackView(views: [icon, info])
        product.orientation = .horizontal
        product.alignment = .centerY
        product.spacing = 25
        let productCard = CardView(content: product, padding: 24)

        let developerTitle = UI.label("Developer", size: 11, weight: .semibold, color: .tertiaryLabelColor)
        let developerName = UI.label("Md Rakib Hossain", size: 19, weight: .bold)
        let developerDetail = UI.wrappingLabel(
            "Designed and maintained to provide a dependable, private and polished Bangla typing experience on Mac.",
            size: 12.5,
            color: .secondaryLabelColor
        )
        let developerStack = NSStackView(views: [developerTitle, developerName, developerDetail])
        developerStack.orientation = .vertical
        developerStack.alignment = .leading
        developerStack.spacing = 7
        let developerCard = CardView(content: developerStack, padding: 20)

        let github = UI.linkButton(
            title: "GitHub Repository",
            symbol: "chevron.left.forwardslash.chevron.right",
            url: "https://github.com/mdrakibhossainkst/amar-avro-keyboard"
        )
        let facebook = UI.linkButton(
            title: "Facebook",
            symbol: "person.crop.circle.fill",
            url: "https://www.facebook.com/itsrakiblxp"
        )
        let links = NSStackView(views: [github, facebook])
        links.orientation = .horizontal
        links.distribution = .fillEqually
        links.spacing = 12
        let linksCard = CardView(title: "Connect", content: links)

        let stack = UI.pageStack([header, productCard, developerCard, linksCard])
        addPinned(stack)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Components

private final class CardView: NSVisualEffectView {
    init(title: String? = nil, content: NSView, padding: CGFloat = 18) {
        super.init(frame: .zero)
        material = .contentBackground
        blendingMode = .withinWindow
        state = .active
        wantsLayer = true
        layer?.cornerRadius = 16
        layer?.masksToBounds = true
        layer?.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false

        content.translatesAutoresizingMaskIntoConstraints = false
        let arranged: [NSView]
        if let title {
            arranged = [UI.label(title, size: 14, weight: .semibold), content]
        } else {
            arranged = [content]
        }
        let stack = NSStackView(views: arranged)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = title == nil ? 0 : 13
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
        updateSurface()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateSurface()
    }

    private func updateSurface() {
        effectiveAppearance.performAsCurrentDrawingAppearance {
            layer?.borderColor = NSColor.labelColor.withAlphaComponent(0.10).cgColor
        }
    }
}

private final class StatusBadge: NSView {
    init(text: String) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.08).cgColor
        translatesAutoresizingMaskIntoConstraints = false

        let label = UI.label(text, size: 9.5, weight: .bold, color: .secondaryLabelColor)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UI helpers

private enum Brand {
    static var appIcon: NSImage {
        if let path = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
           let image = NSImage(contentsOfFile: path) {
            return image
        }
        return NSApp.applicationIconImage
    }
}

private enum UI {
    static func label(
        _ text: String,
        size: CGFloat,
        weight: NSFont.Weight,
        color: NSColor = .labelColor
    ) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    static func wrappingLabel(
        _ text: String,
        size: CGFloat,
        color: NSColor = .labelColor
    ) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: size)
        label.textColor = color
        label.maximumNumberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    static func pageHeader(title: String, subtitle: String) -> NSView {
        let titleLabel = label(title, size: 30, weight: .bold)
        let subtitleLabel = wrappingLabel(subtitle, size: 13.5, color: .secondaryLabelColor)
        let stack = NSStackView(views: [titleLabel, subtitleLabel])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        return stack
    }

    static func pageStack(_ views: [NSView]) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        for view in views {
            view.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }
        return stack
    }

    static func divider() -> NSView {
        let divider = NSBox()
        divider.boxType = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }

    static func stepRow(number: String, title: String, detail: String) -> NSView {
        let numberView = StatusBadge(text: number)
        numberView.widthAnchor.constraint(greaterThanOrEqualToConstant: 26).isActive = true
        let titleLabel = label(title, size: 13.5, weight: .semibold)
        let detailLabel = wrappingLabel(detail, size: 12, color: .secondaryLabelColor)
        let text = NSStackView(views: [titleLabel, detailLabel])
        text.orientation = .vertical
        text.alignment = .leading
        text.spacing = 3
        let row = NSStackView(views: [numberView, text])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 13
        return row
    }

    static func exampleChip(input: String, output: String) -> NSView {
        let inputLabel = label(input, size: 12, weight: .medium, color: .secondaryLabelColor)
        let outputLabel = label(output, size: 20, weight: .semibold)
        let stack = NSStackView(views: [inputLabel, outputLabel])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 5
        let card = CardView(content: stack, padding: 12)
        return card
    }

    static func mapping(_ input: String, _ output: String) -> NSView {
        let key = label(input, size: 12, weight: .semibold, color: .secondaryLabelColor)
        let arrow = label("→", size: 12, weight: .medium, color: .tertiaryLabelColor)
        let result = label(output, size: 18, weight: .semibold)
        let row = NSStackView(views: [key, arrow, result])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 8
        let card = CardView(content: row, padding: 11)
        card.widthAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        return card
    }

    static func phraseRow(_ input: String, _ output: String) -> NSView {
        let inputLabel = label(input, size: 12.5, weight: .medium, color: .secondaryLabelColor)
        let outputLabel = label(output, size: 16, weight: .semibold)
        let spacer = NSView()
        let row = NSStackView(views: [inputLabel, spacer, outputLabel])
        row.orientation = .horizontal
        row.alignment = .centerY
        return row
    }

    static func linkButton(title: String, symbol: String, url: String) -> NSButton {
        let button = NSButton(title: title, target: LinkHandler.shared, action: #selector(LinkHandler.open(_:)))
        button.identifier = NSUserInterfaceItemIdentifier(url)
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
        button.imagePosition = .imageLeading
        button.contentTintColor = .labelColor
        button.bezelStyle = .rounded
        button.controlSize = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 38).isActive = true
        return button
    }
}

private final class LinkHandler: NSObject {
    static let shared = LinkHandler()

    @objc func open(_ sender: NSButton) {
        guard let raw = sender.identifier?.rawValue, let url = URL(string: raw) else { return }
        NSWorkspace.shared.open(url)
    }
}

private extension NSView {
    func addPinned(_ child: NSView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: topAnchor),
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.trailingAnchor.constraint(equalTo: trailingAnchor),
            child.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        ])
    }
}
