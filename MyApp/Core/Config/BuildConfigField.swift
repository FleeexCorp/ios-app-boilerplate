/// Names the fields of ``BuildConfig``, in validation order.
///
/// Raw values are what the configuration error screen renders. They are names only: a
/// value carries deployment detail that has no business being shown on a device.
enum BuildConfigField: String, CaseIterable, Sendable {
    case apiBaseUrl
}
