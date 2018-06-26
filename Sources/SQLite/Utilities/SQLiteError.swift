#if os(Linux)
import CSQLite
#else
import SQLite3
#endif
import Debugging

/// Errors that can be thrown while using SQLite
public struct SQLiteError: SQLError {
    public let type: SQLErrorType
    public let statusCode: Int32?
    public let reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var identifier: String {
        var identifier = type.description
        if let statusCode = self.statusCode {
            identifier += " (status code: \(statusCode))"
        }
        return identifier
    }

    /// Create an error from a manual problem and reason.
    init(type: SQLErrorType, reason: String, source: SourceLocation) {
        self.statusCode = nil
        self.type = type
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = SQLiteError.makeStackTrace()
    }

    /// Dynamically generate an error from status code and database.
    init(
        statusCode: Int32,
        connection: SQLiteConnection,
        source: SourceLocation
    ) {
        self.statusCode = statusCode
        self.type = SQLErrorType(statusCode: statusCode)
        self.reason = connection.errorMessage ?? "Unknown"
        self.sourceLocation = source
        self.stackTrace = SQLiteError.makeStackTrace()
    }
}

/// Problem kinds.
internal extension SQLErrorType {
    init(statusCode: Int32) {
        switch statusCode {
        case SQLITE_ERROR:
            self = .unknown
        case SQLITE_INTERNAL:
            self = .intern
        case SQLITE_PERM:
            self = .permission
        case SQLITE_ABORT:
            self = .abort
        case SQLITE_BUSY:
            self = .busy
        case SQLITE_LOCKED:
            self = .locked
        case SQLITE_NOMEM:
            self = .memory
        case SQLITE_READONLY:
            self = .readOnly
        case SQLITE_INTERRUPT:
            self = .abort
        case SQLITE_IOERR:
            self = .ioError
        case SQLITE_CORRUPT:
            self = .invalidDatabase
        case SQLITE_NOTFOUND:
            self = .ioError
        case SQLITE_FULL:
            self = .ioError
        case SQLITE_CANTOPEN:
            self = .ioError
        case SQLITE_PROTOCOL:
            self = .unknown
        case SQLITE_EMPTY:
            self = .unknown // not used according to the doc
        case SQLITE_SCHEMA:
            self = .unknown
        case SQLITE_TOOBIG:
            self = .invalidData
        case SQLITE_CONSTRAINT:
          self = .constraint
        case SQLITE_MISMATCH:
            self = .invalidData
        case SQLITE_MISUSE:
            self = .invalidRequest
        case SQLITE_NOLFS:
            self = .ioError
        case SQLITE_AUTH:
            self = .permission
        case SQLITE_FORMAT:
            self = .unknown // not used according to the doc
        case SQLITE_RANGE:
          self = .unknownEntity
        case SQLITE_NOTADB:
            self = .invalidDatabase
        default:
            self = .unknown
        }
    }
}
