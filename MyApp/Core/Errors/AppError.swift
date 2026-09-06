/// What can go wrong between the app and the outside, said in the app's own words.
///
/// Views never see a transport error or an `Error.localizedDescription`: the API layer maps
/// every failure to one of these, the view model turns ``messageKey`` into a sentence from
/// `Localizable.xcstrings`, and ``technicalNote`` (a status, a request id) sits behind a
/// disclosure for the person who will file the bug.
struct AppError: Error, Sendable, Equatable {
    enum Kind: Sendable, Equatable {
        /// No network at all.
        case offline

        /// The request went out and nothing came back in time.
        case timeout

        /// The session is over: the user has to sign in again.
        case unauthorized

        /// The server answered with a failure status.
        case server(status: Int)

        /// The server answered something the app could not read.
        case decoding

        case unknown
    }

    let kind: Kind

    /// Machine detail for a bug report, never the message itself.
    let technicalNote: String?

    init(_ kind: Kind, technicalNote: String? = nil) {
        self.kind = kind
        self.technicalNote = technicalNote
    }

    /// The `Localizable.xcstrings` key of the sentence the user reads.
    var messageKey: String {
        switch kind {
        case .offline: "error.offline"
        case .timeout: "error.timeout"
        case .unauthorized: "error.unauthorized"
        case .server: "error.server"
        case .decoding: "error.decoding"
        case .unknown: "error.unknown"
        }
    }
}
