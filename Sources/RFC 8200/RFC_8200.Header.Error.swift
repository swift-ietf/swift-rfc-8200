public import RFC_4291

extension RFC_8200.Header {
    /// Errors that can occur when parsing IPv6 headers
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The byte sequence is too short (need at least 40 bytes)
        case invalidLength(_ length: Int)

        /// The version field is not 6
        case invalidVersion(_ version: UInt8)

        /// The source address could not be parsed
        case invalidSourceAddress(_ underlying: RFC_4291.IPv6.Address.Error)

        /// The destination address could not be parsed
        case invalidDestinationAddress(_ underlying: RFC_4291.IPv6.Address.Error)
    }
}

extension RFC_8200.Header.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidLength(let length):
            return "IPv6 header requires at least 40 bytes, got \(length)"
        case .invalidVersion(let version):
            return "Invalid IP version \(version), expected 6"
        case .invalidSourceAddress(let error):
            return "Invalid source address: \(error)"
        case .invalidDestinationAddress(let error):
            return "Invalid destination address: \(error)"
        }
    }
}
