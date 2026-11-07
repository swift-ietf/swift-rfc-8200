extension RFC_8200 {
    /// Traffic Class field (8 bits)
    ///
    /// The Traffic Class field in the IPv6 header is divided into:
    /// - DSCP (Differentiated Services Code Point): 6 bits
    /// - ECN (Explicit Congestion Notification): 2 bits
    ///
    /// ## Format
    ///
    /// ```
    /// +---+---+---+---+---+---+---+---+
    /// |         DSCP          | ECN   |
    /// +---+---+---+---+---+---+---+---+
    /// ```
    ///
    /// ## See Also
    ///
    /// - RFC 2474: Definition of the Differentiated Services Field
    /// - RFC 3168: Explicit Congestion Notification
    public struct TrafficClass: RawRepresentable, Sendable, Hashable, Codable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a TrafficClass from DSCP and ECN values
        ///
        /// - Parameters:
        ///   - dscp: Differentiated Services Code Point (0-63)
        ///   - ecn: Explicit Congestion Notification (0-3)
        public init(dscp: UInt8, ecn: UInt8) {
            self.rawValue = ((dscp & 0x3F) << 2) | (ecn & 0x03)
        }

        /// Differentiated Services Code Point (6 bits)
        public var dscp: UInt8 {
            (rawValue >> 2) & 0x3F
        }

        /// Explicit Congestion Notification (2 bits)
        public var ecn: UInt8 {
            rawValue & 0x03
        }

        /// Default traffic class (0)
        public static let `default` = Self(rawValue: 0)

        /// Class Selector 0 (Best Effort)
        public static let cs0 = Self(dscp: 0, ecn: 0)

        /// Class Selector 1
        public static let cs1 = Self(dscp: 8, ecn: 0)

        /// Class Selector 2
        public static let cs2 = Self(dscp: 16, ecn: 0)

        /// Class Selector 3
        public static let cs3 = Self(dscp: 24, ecn: 0)

        /// Class Selector 4
        public static let cs4 = Self(dscp: 32, ecn: 0)

        /// Class Selector 5
        public static let cs5 = Self(dscp: 40, ecn: 0)

        /// Class Selector 6 (Network Control)
        public static let cs6 = Self(dscp: 48, ecn: 0)

        /// Class Selector 7
        public static let cs7 = Self(dscp: 56, ecn: 0)

        /// Expedited Forwarding (RFC 3246)
        public static let ef = Self(dscp: 46, ecn: 0)

        /// Not ECN-Capable Transport
        public static let notECT: UInt8 = 0

        /// ECN-Capable Transport (0)
        public static let ect0: UInt8 = 2

        /// ECN-Capable Transport (1)
        public static let ect1: UInt8 = 1

        /// Congestion Experienced
        public static let ce: UInt8 = 3
    }
}
