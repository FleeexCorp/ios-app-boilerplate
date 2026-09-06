/// A holder of state that belongs to one signed-in session.
///
/// Stores outlive a sign-out: the same instance is still there when the next user signs
/// in, so anything it cached would leak across accounts. Implementing this gives one
/// agreed way to drop that state, and to disown whatever is still in flight so a
/// response landing after the switch cannot resurrect the previous user's data.
@MainActor
protocol Resettable: AnyObject {
    /// Drops everything the holder cached for the session that just ended.
    func reset()
}
