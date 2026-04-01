import Foundation

enum GameData {
    static func categories(for grade: GradeLevel) -> [WordCategory] {
        let base = baseCategories(for: grade)
        let robot = robotCategory(for: grade, using: base)
        return [robot] + base
    }

    private static func robotCategory(for grade: GradeLevel, using base: [WordCategory]) -> WordCategory {
        let gradeWords = base.flatMap(\.words)
        let mysteryWords = gradeWords.map {
            PuzzleWord(
                answer: $0.answer,
                clue: "Robot Rob picked a mystery \(grade.rawValue.lowercased()) word!",
                emoji: "🤖"
            )
        }

        return WordCategory(
            name: "Robot Rob Mystery",
            description: "Mixed words for \(grade.rawValue). Robot Rob chooses the challenge!",
            icon: "🤖",
            words: mysteryWords,
            isRobotCategory: true
        )
    }

    private static func baseCategories(for grade: GradeLevel) -> [WordCategory] {
        switch grade {
        case .preK:
            return [
                WordCategory(
                    name: "Animal Friends",
                    description: "Cute animals kids love.",
                    icon: "🐾",
                    words: [
                        w("cat", "This pet says meow.", "🐱"),
                        w("dog", "This pet says woof.", "🐶"),
                        w("duck", "This animal says quack.", "🦆"),
                        w("fish", "It swims in water.", "🐟"),
                        w("bear", "A big fuzzy forest friend.", "🐻"),
                        w("frog", "It hops and says ribbit.", "🐸")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Things That Go",
                    description: "Vehicles and movement words.",
                    icon: "🚗",
                    words: [
                        w("car", "A small ride with wheels.", "🚗"),
                        w("bus", "A big ride to school.", "🚌"),
                        w("bike", "You pedal this to move.", "🚲"),
                        w("boat", "This floats on water.", "⛵️"),
                        w("train", "It rides on tracks.", "🚂"),
                        w("van", "A roomy family ride.", "🚐")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Colors & Shapes",
                    description: "Bright words kids already know.",
                    icon: "🎨",
                    words: [
                        w("red", "The color of many apples.", "🍎"),
                        w("blue", "The color of the sky.", "🩵"),
                        w("green", "The color of grass.", "💚"),
                        w("star", "A twinkly shape in the sky.", "⭐️"),
                        w("heart", "A shape that means love.", "❤️"),
                        w("circle", "A round shape.", "⚪️")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Home & Feelings",
                    description: "Family and everyday feeling words.",
                    icon: "🏡",
                    words: [
                        w("mom", "A caring grown-up at home.", "👩"),
                        w("dad", "A caring grown-up at home.", "👨"),
                        w("baby", "Very young and tiny.", "👶"),
                        w("hug", "A cozy squeeze from someone you love.", "🤗"),
                        w("smile", "A happy face expression.", "😊"),
                        w("happy", "A joyful feeling.", "😁")
                    ],
                    isRobotCategory: false
                )
            ]

        case .kindergarten:
            return [
                WordCategory(
                    name: "Weather Watch",
                    description: "Sky and weather words.",
                    icon: "🌦️",
                    words: [
                        w("rain", "Water drops from the sky.", "🌧️"),
                        w("sunny", "Bright sky and sunshine.", "☀️"),
                        w("cloud", "A fluffy shape in the sky.", "☁️"),
                        w("storm", "Big wind and rain.", "⛈️"),
                        w("wind", "Moving air you can feel.", "💨"),
                        w("snow", "White flakes from the sky.", "❄️")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Plants & Bugs",
                    description: "Nature words that feel hands-on.",
                    icon: "🌱",
                    words: [
                        w("seed", "A tiny starter for a plant.", "🌰"),
                        w("plant", "A green living thing.", "🪴"),
                        w("leaf", "A green part of a plant.", "🍃"),
                        w("flower", "A colorful blooming plant.", "🌸"),
                        w("bee", "A buzzing pollinator.", "🐝"),
                        w("ant", "A tiny crawling insect.", "🐜")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Community Helpers",
                    description: "Everyday hero jobs.",
                    icon: "🧑‍🚒",
                    words: [
                        w("teacher", "Helps kids learn at school.", "🧑‍🏫"),
                        w("nurse", "Helps people feel better.", "🩺"),
                        w("doctor", "Checks your health.", "👨‍⚕️"),
                        w("chef", "Cooks yummy meals.", "👩‍🍳"),
                        w("pilot", "Flies an airplane.", "🧑‍✈️"),
                        w("farmer", "Grows food on a farm.", "👩‍🌾")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Animal Homes",
                    description: "Where animals live.",
                    icon: "🏞️",
                    words: [
                        w("nest", "A bird home in a tree.", "🪺"),
                        w("pond", "A small body of water.", "🫧"),
                        w("cave", "A rocky shelter.", "🕳️"),
                        w("den", "A cozy animal home.", "🦊"),
                        w("hive", "A bee home.", "🍯"),
                        w("reef", "An underwater sea home.", "🪸")
                    ],
                    isRobotCategory: false
                )
            ]

        case .first:
            return [
                WordCategory(
                    name: "Space Explorer",
                    description: "Adventure words from space.",
                    icon: "🚀",
                    words: [
                        w("moon", "Earth's bright night friend.", "🌙"),
                        w("star", "A shining light in space.", "⭐️"),
                        w("planet", "A world in orbit.", "🪐"),
                        w("comet", "An icy rock with a tail.", "☄️"),
                        w("orbit", "A path around a planet.", "🛰️"),
                        w("rocket", "A fast spacecraft launch.", "🚀")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Light & Sound Quest",
                    description: "Simple science words in action.",
                    icon: "💡",
                    words: [
                        w("light", "Helps us see.", "💡"),
                        w("sound", "What we hear.", "🔊"),
                        w("echo", "A sound that bounces back.", "🗣️"),
                        w("drum", "You tap this for music.", "🥁"),
                        w("bell", "It rings with a clear tone.", "🔔"),
                        w("flash", "A quick burst of light.", "📸")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Super Senses",
                    description: "Words about how our body explores.",
                    icon: "🧠",
                    words: [
                        w("sight", "Use your eyes to do this.", "👀"),
                        w("smell", "Use your nose to do this.", "👃"),
                        w("taste", "Use your tongue to do this.", "👅"),
                        w("touch", "Use your hands to do this.", "✋"),
                        w("ear", "Body part used for hearing.", "👂"),
                        w("nose", "Body part used for smell.", "👃")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Build & Solve",
                    description: "Engineering and puzzle words.",
                    icon: "🧩",
                    words: [
                        w("bridge", "Helps you cross over water.", "🌉"),
                        w("wheel", "A round part that rolls.", "🛞"),
                        w("gear", "A toothed wheel in machines.", "⚙️"),
                        w("puzzle", "A game of matching pieces.", "🧩"),
                        w("tower", "A tall building shape.", "🗼"),
                        w("block", "A building piece.", "🧱")
                    ],
                    isRobotCategory: false
                )
            ]

        case .second:
            return [
                WordCategory(
                    name: "Water & Earth Adventure",
                    description: "Land and water world words.",
                    icon: "🌎",
                    words: [
                        w("river", "Water that flows.", "🏞️"),
                        w("ocean", "A huge body of salt water.", "🌊"),
                        w("mountain", "Very high land.", "⛰️"),
                        w("valley", "Low land between hills.", "🏔️"),
                        w("canyon", "A deep rocky gap.", "🪨"),
                        w("island", "Land surrounded by water.", "🏝️")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Matter Lab",
                    description: "Hands-on states of matter.",
                    icon: "🧪",
                    words: [
                        w("solid", "Keeps its shape.", "🧊"),
                        w("liquid", "Flows and fills containers.", "💧"),
                        w("gas", "Spreads to fill space.", "💨"),
                        w("metal", "Strong shiny material.", "🪙"),
                        w("wood", "Comes from trees.", "🪵"),
                        w("steam", "Hot water in the air.", "♨️")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Plant Power",
                    description: "Plant part words that build knowledge.",
                    icon: "🌿",
                    words: [
                        w("root", "Part underground that drinks water.", "🥕"),
                        w("stem", "The main plant support.", "🌱"),
                        w("petal", "Soft colorful flower part.", "🌸"),
                        w("pollen", "Tiny powder made by flowers.", "🌼"),
                        w("sprout", "A new baby plant.", "🌱"),
                        w("garden", "A place where plants grow.", "🪴")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Habitat Detectives",
                    description: "Ecosystem words kids love to explore.",
                    icon: "🔎",
                    words: [
                        w("forest", "Land filled with trees.", "🌳"),
                        w("desert", "Dry sandy habitat.", "🏜️"),
                        w("jungle", "A warm, dense forest.", "🌴"),
                        w("tundra", "A very cold habitat.", "🧊"),
                        w("savanna", "Grassy habitat with big animals.", "🦓"),
                        w("reef", "A lively ocean habitat.", "🪸")
                    ],
                    isRobotCategory: false
                )
            ]

        case .third:
            return [
                WordCategory(
                    name: "Eco Heroes",
                    description: "Big idea words for caring for Earth.",
                    icon: "♻️",
                    words: [
                        w("recycle", "Turn old things into new things.", "♻️"),
                        w("energy", "Power we use every day.", "⚡️"),
                        w("nature", "The world of plants and animals.", "🌿"),
                        w("planet", "Our home world.", "🌍"),
                        w("reuse", "Use something again.", "🧴"),
                        w("compost", "Food scraps that help soil.", "🍂")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Weather Detectives",
                    description: "Forecast and climate words.",
                    icon: "🌪️",
                    words: [
                        w("climate", "Long-term weather pattern.", "🌤️"),
                        w("forecast", "A weather prediction.", "📡"),
                        w("thunder", "Loud storm sound.", "⛈️"),
                        w("breeze", "A gentle wind.", "🍃"),
                        w("drought", "Long time with little rain.", "🥵"),
                        w("flood", "Too much water on land.", "🌊")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Forces & Motion",
                    description: "Physics words made kid-friendly.",
                    icon: "🧲",
                    words: [
                        w("magnet", "Pulls certain metals.", "🧲"),
                        w("motion", "The act of moving.", "🏃"),
                        w("friction", "Force that slows movement.", "🛹"),
                        w("gravity", "Force that pulls things down.", "🍎"),
                        w("push", "Move something away.", "👉"),
                        w("pull", "Move something toward you.", "🫱")
                    ],
                    isRobotCategory: false
                ),
                WordCategory(
                    name: "Life Cycles",
                    description: "Growth and change words from nature.",
                    icon: "🦋",
                    words: [
                        w("larva", "An early insect stage.", "🐛"),
                        w("pupa", "Middle insect stage.", "🦋"),
                        w("adult", "Fully grown stage.", "🧑"),
                        w("hatch", "Break out of an egg.", "🥚"),
                        w("seedling", "A tiny young plant.", "🌱"),
                        w("metamorph", "A big body change in life cycle.", "🦋")
                    ],
                    isRobotCategory: false
                )
            ]
        }
    }

    private static func w(_ answer: String, _ clue: String, _ emoji: String) -> PuzzleWord {
        PuzzleWord(answer: answer, clue: clue, emoji: emoji)
    }
}
