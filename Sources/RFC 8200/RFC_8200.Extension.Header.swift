public import Binary
public import Byte


extension RFC_8200.Extension {
    /// Generic extension header format
    ///
    /// Most extension headers (except Fragment) follow this format:
    /// - Next Header (8 bits)
    /// - Header Extension Length (8 bits, in 8-octet units, excluding first 8)
    /// - Type-specific data
    public struct Header: Sendable, Hashable {
        /// Next header type
        public let nextHeader: RFC_8200.NextHeader

        /// Header length in 8-octet units (excluding first 8 octets)
        public let headerLength: UInt8

        /// The full length of the header in bytes
        public var lengthInBytes: Int {
            (Int(headerLength) + 1) * 8
        }
    }
}
