/// RFC 8200: Internet Protocol, Version 6 (IPv6) Specification
///
/// This namespace contains types for the IPv6 packet format as defined
/// in RFC 8200 from July 2017.
///
/// ## Key Types
///
/// - ``Header``: The 40-byte fixed IPv6 header
/// - ``NextHeader``: Protocol type field values
/// - ``TrafficClass``: Traffic class (DSCP + ECN)
/// - ``FlowLabel``: 20-bit flow label
/// - ``Extension``: Extension header types
///
/// ## Packet Structure
///
/// ```
/// +---------------+---------------+---------------+---------------+
/// |Version| Traffic Class |           Flow Label                  |
/// +---------------+---------------+---------------+---------------+
/// |         Payload Length        |  Next Header  |   Hop Limit   |
/// +---------------+---------------+---------------+---------------+
/// |                                                               |
/// +                         Source Address                        +
/// |                            (128 bits)                         |
/// +---------------+---------------+---------------+---------------+
/// |                                                               |
/// +                      Destination Address                      +
/// |                            (128 bits)                         |
/// +---------------+---------------+---------------+---------------+
/// ```
///
/// ## Example
///
/// ```swift
/// // Create an IPv6 header
/// let header = try RFC_8200.Header(
///     trafficClass: .default,
///     flowLabel: .zero,
///     payloadLength: 100,
///     nextHeader: .tcp,
///     hopLimit: 64,
///     source: .loopback,
///     destination: .loopback
/// )
///
/// // Serialize to bytes
/// var buffer: [UInt8] = []
/// RFC_8200.Header.serialize(header, into: &buffer)
/// // buffer.count == 40
/// ```
///
/// ## See Also
///
/// - [RFC 8200](https://www.rfc-editor.org/rfc/rfc8200)
/// - ``RFC_4291`` for IPv6 addressing
public enum RFC_8200 {}

extension RFC_8200 {
    /// IPv6 protocol version
    ///
    /// Always 6 for IPv6 packets.
    public static let version: UInt8 = 6

    /// Fixed header size in bytes
    ///
    /// The IPv6 header is always exactly 40 bytes.
    public static let headerSize: Int = 40
}
