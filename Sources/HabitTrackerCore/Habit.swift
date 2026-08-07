import Foundation
import SwiftData

public enum HabitStatus: String, Codable, Sendable {
    case active
    case archived
}

@Model
public final class Habit {
    public var id: UUID
    public var name: String
    public var status: HabitStatus
    public var createdDay: String
    public var archivedDay: String?

    public init(
        id: UUID = UUID(),
        name: String,
        status: HabitStatus = .active,
        createdDay: String,
        archivedDay: String? = nil
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.createdDay = createdDay
        self.archivedDay = archivedDay
    }
}