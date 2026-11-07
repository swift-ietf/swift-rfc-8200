extension RFC_8200 {
    /// Flow Label field (20 bits)
    ///
    /// The Flow Label is used to identify packets belonging to the same flow.
    /// A flow is a sequence of packets sent from a particular source to a
    /// particular unicast or multicast destination.
    ///
    /// ## Constraints
    ///
    /// - 20-bit value (0 to 0xFFFFF)
    /// - Value of 0 means no flow label
    /// - Non-zero values should be pseudo-randomly chosen
    ///
    /// ## See Also
    ///
    /// - RFC 6437: IPv6 Flow Label Specification
    public struct FlowLabel: RawRepresentable, Sendable, Hashable, Codable, Comparable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue & 0xFFFFF
        }

        /// Creates a FlowLabel WITHOUT validation
        init(__unchecked: Void, rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Zero flow label (no flow identification)
        public static let zero = Self(__unchecked: (), rawValue: 0)

        /// Maximum flow label value
        public static let max = Self(__unchecked: (), rawValue: 0xFFFFF)

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
