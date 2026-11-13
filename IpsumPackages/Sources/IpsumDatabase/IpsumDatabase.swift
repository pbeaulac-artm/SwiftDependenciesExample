import IpsumModels

public actor IpsumDatabase {
    private let storage: [IpsumStyle: [IpsumEntry]]

    public init() {
        let paragraphs: [IpsumStyle: [String]] = [
            .lorem: [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                "Vivamus vitae lorem. Integer porta, sapien vel tempor, risus erat.",
                "Donec at ipsum. Sed posuere neque, eu blandit libero.",
                "Nullam fermentum lorem, quis tincidunt ipsum, vitae volutpat dolor."
            ],
            .beer: [
                "Amber malt, golden hops. A bright lager meets a toasted barley finish.",
                "Foamy stout, copper ale. The kettle hums and the yeast takes its time.",
                "Citrus hops drift over biscuit malt, with a crisp and gentle finish.",
                "A velvet porter pours slowly; roasted grain and caramel fill the glass."
            ],
            .coffee: [
                "Espresso crema, roasted beans. A quiet morning begins with a warm cup.",
                "Cappuccino clouds meet cocoa notes and a smooth caramel finish.",
                "Pour-over bloom, paper filter. Fresh grounds unfold one drop at a time.",
                "A little latte, a long conversation, and the scent of toasted coffee."
            ],
            .space: [
                "Orbit ipsum, nebula shimmer. A small probe follows the light of distant stars.",
                "Lunar dust and solar wind trace a silent path through the galaxy.",
                "The capsule glides past Saturn, carrying a telescope and a thousand questions.",
                "Beyond the asteroid belt, a blue planet shines against the cosmic night."
            ],
            .pirate: [
                "Ahoy ipsum! Hoist the canvas and follow the gulls beyond the harbour.",
                "A compass, a map, and a wooden chest wait beneath the captain's table.",
                "The crew sings softly as the ship rides a silver moonlit sea.",
                "Land ahead, matey! Drop the anchor and bring the treasure map ashore."
            ]
        ]
        storage = paragraphs.mapValues { texts in
            texts.enumerated().map { IpsumEntry(id: String($0.offset), text: $0.element) }
        }
    }

    public func entries(for style: IpsumStyle) -> [IpsumEntry] {
        guard let entries = storage[style] else {
            preconditionFailure("Missing ipsum table: \(style.rawValue)")
        }
        return entries
    }
}
