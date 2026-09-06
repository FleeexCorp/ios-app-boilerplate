/// How a write and the re-read behind it went, kept apart on purpose.
///
/// A mutation that succeeded and a refresh that failed are two different things, and
/// collapsing them into one failure is the worse lie: the app would tell the user the
/// change did not happen while it did. The screen shows the success and a "could not
/// refresh" note with a retry.
enum MutationResult: Sendable, Equatable {
    /// The write landed and the state on screen is current.
    case succeeded

    /// The write landed; the re-read that followed did not, so what is on screen is what
    /// was there before.
    case succeededButRefreshFailed(AppError)

    /// The write did not land. Nothing changed.
    case failed(AppError)
}
