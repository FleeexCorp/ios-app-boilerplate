/// Where one piece of loaded state stands.
///
/// ``loading(previous:)`` and ``failed(_:previous:)`` carry what was on screen before the
/// attempt, which is what lets a refresh that failed show stale data with a note instead
/// of a blank: the user keeps what they were reading, and is told it may have moved.
enum LoadState<Value: Sendable>: Sendable {
    /// Nothing has been asked for yet.
    case idle

    /// A read is in flight, over whatever was already there.
    case loading(previous: Value?)

    case loaded(Value)

    /// The read failed, over whatever was already there.
    case failed(AppError, previous: Value?)

    /// The freshest value there is, stale or not, and `nil` when there has never been one.
    var value: Value? {
        switch self {
        case .idle: nil
        case let .loading(previous): previous
        case let .loaded(value): value
        case let .failed(_, previous): previous
        }
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    /// `true` only for a value the server actually confirmed.
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }

        return false
    }

    /// Why the last attempt failed, `nil` when it did not.
    var error: AppError? {
        guard case let .failed(error, _) = self else {
            return nil
        }

        return error
    }

    /// Nothing to show and nothing to explain: the first read has not answered yet.
    ///
    /// What tells a skeleton apart from an inline error and from stale content: only a
    /// state that has neither can be replaced wholesale by a placeholder.
    var isPriming: Bool {
        value == nil && error == nil
    }

    /// This state with a fresh attempt started over it.
    var reloading: LoadState {
        .loading(previous: value)
    }

    /// The same state over a transformed value.
    ///
    /// A view model projects what a store holds into what a card draws without losing
    /// which of the four states it is in, error and stale value included.
    func mapValue<Mapped>(_ transform: (Value) -> Mapped) -> LoadState<Mapped> {
        switch self {
        case .idle: .idle
        case let .loading(previous): .loading(previous: previous.map(transform))
        case let .loaded(value): .loaded(transform(value))
        case let .failed(error, previous): .failed(error, previous: previous.map(transform))
        }
    }

    /// What a finished attempt leaves behind.
    func settled(_ result: Result<Value, AppError>) -> LoadState {
        switch result {
        case let .success(value): .loaded(value)
        case let .failure(error): .failed(error, previous: value)
        }
    }
}

extension LoadState: Equatable where Value: Equatable {}
