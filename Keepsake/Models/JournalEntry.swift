import Foundation
import SwiftUI

enum EntryType: String, Codable {
    case openJournal
    case written
    case chat
    case picture
    case voice
    case blank
}

class JournalEntry: ObservableObject, Identifiable, Hashable, Codable {
    var id: UUID
    var date: String
    var title: String
    var width: Int
    var height: Int
    var isFake: Bool
    var color: [Double]
    var entryContents: String
    var type: EntryType
    
    var entrySize: EntrySize {
        switch (width, height) {
        case (1, 1):
            return .small
        case (2, 1), (1, 2):
            return .medium
        default:
            return .large
        }
    }

    // Computed properties for layout
    var frameWidth: CGFloat {
        UIScreen.main.bounds.width * 0.38 * CGFloat(width) + UIScreen.main.bounds.width * 0.02 * CGFloat(width - 1)
    }

    var frameHeight: CGFloat {
        UIScreen.main.bounds.height * 0.12 * CGFloat(height) + UIScreen.main.bounds.width * 0.02 * CGFloat(height - 1)
    }
    
    init() {
        self.id = UUID()
        self.date = "01/01/2000"
        self.title = "Title"
        self.entryContents = "It's a good day"
        self.width = 1
        self.height = 1
        self.isFake = true
        self.color = [0.5, 0.5, 0.5]
        self.type = .written
    }

    init(id: UUID = UUID(), date: String, title: String, entryContents: String, width: Int = 1, height: Int = 1, isFake: Bool = false, color: [Double] = [0.5,0.5,0.5], type: EntryType) {
        self.id = id
        self.date = date
        self.title = title
        self.width = width
        self.height = height
        self.isFake = isFake
        self.color = color
        self.type = type
        self.entryContents = entryContents
    }
    
//    init(entry: JournalEntry, width: Int, height: Int) {
//        self.id = UUID()
//        self.date = entry.date
//        self.title = entry.title
//        self.width = width
//        self.height = height
//        self.isFake = entry.isFake
//        self.color = entry.color
//        self.type = entry.type
//        self.entryContents = entry.entryContents
//    }
    
    static func create(from entry: JournalEntry, width: Int, height: Int) -> JournalEntry {
        print(Swift.type(of: entry))
        switch entry.type {
        case .picture:
            let pictureEntry = entry as! PictureEntry
            return PictureEntry(date: pictureEntry.date, title: pictureEntry.title, images: pictureEntry.images, width: width, height: height, isFake: false, color: pictureEntry.color)
        case .voice:
            let voice = entry as! VoiceEntry
            return VoiceEntry(date: voice.date, title: voice.title, audio: voice.audio, transcription: voice.transcription, width: width, height: height, isFake: false, color: voice.color)
        case .chat:
            let chat = entry as! ConversationEntry
            return ConversationEntry(date: chat.date, title: chat.title, conversationLog: chat.conversationLog, width: width, height: height, color: chat.color)
        default:
            let written = entry as! WrittenEntry
            return WrittenEntry(date: written.date, title: written.title, text: written.text, summary: written.summary, width: width, height: height, isFake: false, color: written.color)
        }
    }

    // MARK: - Hashable
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case id, date, title, width, height, isFake, color, images, type, entryContents
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(String.self, forKey: .date)
        self.title = try container.decode(String.self, forKey: .title)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.isFake = try container.decode(Bool.self, forKey: .isFake)
        self.color = try container.decode([Double].self, forKey: .color)
        self.type = try container.decode(EntryType.self, forKey: .type)
        self.entryContents = try container.decode(String.self, forKey: .entryContents)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(title, forKey: .title)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(isFake, forKey: .isFake)
        try container.encode(color, forKey: .color)
        try container.encode(type, forKey: .type)
    }
    
    func toDictionary(journalID: UUID) -> [String: Any] {
        return [
            "id": id.uuidString,
            "date": date,
            "title": title,
            "width": width,
            "entryContents": entryContents,
            "journal_id": journalID.uuidString,
            "height": height,
            "isFake": isFake,
            "color": color,
            "type": type.rawValue
        ]
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "date": date,
            "title": title,
            "width": width,
            "entryContents": entryContents,
            "height": height,
            "isFake": isFake,
            "color": color,
            "type": type.rawValue
        ]
    }
    

    class func fromDictionary(_ dict: [String: Any]) -> JournalEntry? {
        guard let typeRaw = dict["type"] as? String,
              let type = EntryType(rawValue: typeRaw) else { return nil }

        switch type {
        case .written: return WrittenEntry.fromDictionary(dict)
        case .chat: return ConversationEntry.fromDictionary(dict)
        case .picture: return PictureEntry.fromDictionary(dict)
        case .voice: return VoiceEntry.fromDictionary(dict)
        default: return fromBaseDictionary(dict)
        }
    }

    static func fromBaseDictionary(_ dict: [String: Any]) -> JournalEntry? {
        guard let date = dict["date"] as? String,
              let title = dict["title"] as? String,
              let entryContents = dict["entryContents"] as? String,
              let width = dict["width"] as? Int,
              let height = dict["height"] as? Int,
              let isFake = dict["isFake"] as? Bool,
              let color = dict["color"] as? [Double],
              let typeRaw = dict["type"] as? String,
              let type = EntryType(rawValue: typeRaw)
        else { return nil }

        return JournalEntry(date: date, title: title, entryContents: entryContents, width: width, height: height, isFake: isFake, color: color, type: type)
    }
}

class PictureEntry: JournalEntry {
    var images: [String]

    init(id: UUID = UUID(), date: String, title: String, images: [String], width: Int = 1, height: Int = 1, isFake: Bool = false, color: [Double] = [0.5,0.5,0.5]) {
        self.images = images
        super.init(id: id, date: date, title: title, entryContents: "", width: width, height: height, isFake: isFake, color: color, type: .picture)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func toDictionary(journalID: UUID) -> [String: Any] {
        var dict = super.toDictionary(journalID: journalID)
        dict["images"] = images
        return dict
    }

    override static func fromDictionary(_ dict: [String: Any]) -> PictureEntry? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let date = dict["date"] as? String,
              let title = dict["title"] as? String,
              let images = dict["images"] as? [String],
              let width = dict["width"] as? Int,
              let height = dict["height"] as? Int,
              let isFake = dict["isFake"] as? Bool,
              let color = dict["color"] as? [Double]
        else { return nil }

        return PictureEntry(id: id, date: date, title: title, images: images, width: width, height: height, isFake: isFake, color: color)
    }
}


class WrittenEntry: JournalEntry {
    var text: String
    var summary: String

    init(id: UUID = UUID(), date: String, title: String, text: String, summary: String, width: Int = 1, height: Int = 1, isFake: Bool = false, color: [Double] = [0.5,0.5,0.5]) {
        self.text = text
        self.summary = summary
        super.init(id: id, date: date, title: title, entryContents: text, width: width, height: height, isFake: isFake, color: color, type: .written)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func toDictionary(journalID: UUID) -> [String: Any] {
        var dict = super.toDictionary(journalID: journalID)
        dict["text"] = text
        dict["summary"] = summary
        return dict
    }

    override static func fromDictionary(_ dict: [String: Any]) -> WrittenEntry? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let date = dict["date"] as? String,
              let title = dict["title"] as? String,
              let text = dict["text"] as? String,
              let summary = dict["summary"] as? String,
              let width = dict["width"] as? Int,
              let height = dict["height"] as? Int,
              let isFake = dict["isFake"] as? Bool,
              let color = dict["color"] as? [Double]
        else { return nil }

        return WrittenEntry(id: id, date: date, title: title, text: text, summary: summary, width: width, height: height, isFake: isFake, color: color)
    }
}

class ConversationEntry: JournalEntry {
    var conversationLog: [String]

    init(id: UUID = UUID(), date: String, title: String, conversationLog: [String], width: Int = 1, height: Int = 1, color: [Double] = [0.5,0.5,0.5]) {
        self.conversationLog = conversationLog
        super.init(id: id, date: date, title: title, entryContents: conversationLog.description, width: width, height: height, isFake: false, color: color, type: .chat)
    }
    
    override func toDictionary(journalID: UUID) -> [String: Any] {
        var dict = super.toDictionary(journalID: journalID)
        dict["conversationLog"] = conversationLog
        return dict
    }

    override static func fromDictionary(_ dict: [String: Any]) -> ConversationEntry? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let date = dict["date"] as? String,
              let title = dict["title"] as? String,
              let conversationLog = dict["conversationLog"] as? [String],
              let color = dict["color"] as? [Double]
        else { return nil }

        return ConversationEntry(id: id, date: date, title: title, conversationLog: conversationLog, color: color)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class VoiceEntry: JournalEntry {
    var audio: Data?
    var transcription: String
    var audioURL: String?

    init(id: UUID = UUID(), date: String, title: String, audio: Data?, audioURL: String = "", transcription: String = "", width: Int = 1, height: Int = 1, isFake: Bool = false, color: [Double] = [0.5,0.5,0.5]) {
        self.audio = audio
        self.transcription = transcription
        self.audioURL = audioURL
        super.init(id: id, date: date, title: title, entryContents: transcription, width: width, height: height, isFake: isFake, color: color, type: .voice)
    }
    
    override func toDictionary(journalID: UUID) -> [String: Any] {
        var dict = super.toDictionary(journalID: journalID)
        dict["audioURL"] = audioURL
        dict["transcription"] = transcription
        return dict
    }

    override static func fromDictionary(_ dict: [String: Any]) -> VoiceEntry? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let date = dict["date"] as? String,
              let title = dict["title"] as? String,
              let audioURL = dict["audioURL"] as? String,
              let transcription = dict["transcription"] as? String,
              let width = dict["width"] as? Int,
              let height = dict["height"] as? Int,
              let isFake = dict["isFake"] as? Bool,
              let color = dict["color"] as? [Double]
        else { return nil }

        return VoiceEntry(id: id, date: date, title: title, audio: nil, audioURL: audioURL, transcription: transcription, width: width, height: height, isFake: isFake, color: color)
    }
    
    func fetchAudioData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

