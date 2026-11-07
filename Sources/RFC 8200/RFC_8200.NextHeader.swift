extension RFC_8200 {
    /// Next Header field values
    ///
    /// The Next Header field identifies the type of header immediately following
    /// the IPv6 header. It uses the same values as the IPv4 Protocol field.
    ///
    /// ## Extension Headers
    ///
    /// Per RFC 8200 Section 4, extension headers are identified by:
    /// - Hop-by-Hop Options (0)
    /// - Routing (43)
    /// - Fragment (44)
    /// - Encapsulating Security Payload (50)
    /// - Authentication Header (51)
    /// - Destination Options (60)
    ///
    /// ## Upper Layer Protocols
    ///
    /// Common upper layer protocols:
    /// - TCP (6)
    /// - UDP (17)
    /// - ICMPv6 (58)
    public struct NextHeader: RawRepresentable, Sendable, Hashable, Codable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a NextHeader WITHOUT validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Hop-by-Hop Options (0)
        public static let hopByHop = Self(__unchecked: (), rawValue: 0)

        /// Routing Header (43)
        public static let routing = Self(__unchecked: (), rawValue: 43)

        /// Fragment Header (44)
        public static let fragment = Self(__unchecked: (), rawValue: 44)

        /// Encapsulating Security Payload (50)
        public static let esp = Self(__unchecked: (), rawValue: 50)

        /// Authentication Header (51)
        public static let ah = Self(__unchecked: (), rawValue: 51)

        /// Destination Options (60)
        public static let destinationOptions = Self(__unchecked: (), rawValue: 60)

        /// Mobility Header (135)
        public static let mobility = Self(__unchecked: (), rawValue: 135)

        /// Host Identity Protocol (139)
        public static let hip = Self(__unchecked: (), rawValue: 139)

        /// Shim6 Protocol (140)
        public static let shim6 = Self(__unchecked: (), rawValue: 140)

        /// TCP (6)
        public static let tcp = Self(__unchecked: (), rawValue: 6)

        /// UDP (17)
        public static let udp = Self(__unchecked: (), rawValue: 17)

        /// ICMPv6 (58)
        public static let icmpv6 = Self(__unchecked: (), rawValue: 58)

        // swift-format-ignore: DontRepeatTypeInStaticProperties
        /// No Next Header (59)
        ///
        /// Indicates that there is no next header. The payload length
        /// still indicates the length of the payload.
        public static let noNextHeader = Self(__unchecked: (), rawValue: 59)

        /// GRE (47)
        public static let gre = Self(__unchecked: (), rawValue: 47)

        /// SCTP (132)
        public static let sctp = Self(__unchecked: (), rawValue: 132)

        /// Whether this is an extension header
        public var isExtensionHeader: Bool {
            switch rawValue {
            case 0, 43, 44, 50, 51, 60, 135, 139, 140:
                return true
            default:
                return false
            }
        }

        /// Whether this is an upper layer protocol
        public var isUpperLayerProtocol: Bool {
            !isExtensionHeader && rawValue != 59
        }
    }
}

extension RFC_8200.NextHeader: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0: return "Hop-by-Hop Options"
        case 6: return "TCP"
        case 17: return "UDP"
        case 43: return "Routing"
        case 44: return "Fragment"
        case 47: return "GRE"
        case 50: return "ESP"
        case 51: return "AH"
        case 58: return "ICMPv6"
        case 59: return "No Next Header"
        case 60: return "Destination Options"
        case 132: return "SCTP"
        case 135: return "Mobility"
        case 139: return "HIP"
        case 140: return "Shim6"
        default: return "Protocol(\(rawValue))"
        }
    }
}
