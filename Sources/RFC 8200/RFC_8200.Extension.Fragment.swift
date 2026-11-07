public import Binary
public import Byte


extension RFC_8200.Extension {
    /// Fragment Header (RFC 8200 Section 4.5)
    ///
    /// Used when a packet is too large to fit in the path MTU.
    /// Unlike other extension headers, the Fragment header has a fixed
    /// 8-byte format.
    ///
    /// ## Wire Format
    ///
    /// ```
    ///  0                   1                   2                   3
    ///  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |  Next Header  |   Reserved    |      Fragment Offset    |Res|M|
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                         Identification                        |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// ```
    public struct Fragment: Sendable, Hashable {
        /// Next header type
        public let nextHeader: RFC_8200.NextHeader

        /// Fragment offset in 8-octet units
        public let fragmentOffset: UInt16

        /// More fragments flag
        public let moreFragments: Bool

        /// Fragment identification
        public let identification: UInt32

        /// Creates a Fragment header
        public init(
            nextHeader: RFC_8200.NextHeader,
            fragmentOffset: UInt16,
            moreFragments: Bool,
            identification: UInt32
        ) {
            self.nextHeader = nextHeader
            self.fragmentOffset = fragmentOffset & 0x1FFF
            self.moreFragments = moreFragments
            self.identification = identification
        }
    }
}
