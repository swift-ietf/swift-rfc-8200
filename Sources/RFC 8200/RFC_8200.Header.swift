public import Binary
public import Byte
public import RFC_4291

extension RFC_8200 {
    /// IPv6 Header (40 bytes)
    ///
    /// The fixed-length 40-byte header as defined in RFC 8200 Section 3.
    ///
    /// ## Wire Format
    ///
    /// ```
    ///  0                   1                   2                   3
    ///  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |Version| Traffic Class |           Flow Label                  |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |         Payload Length        |  Next Header  |   Hop Limit   |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                                                               |
    /// +                                                               +
    /// |                         Source Address                        |
    /// +                          (128 bits)                           +
    /// |                                                               |
    /// +                                                               +
    /// |                                                               |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                                                               |
    /// +                                                               +
    /// |                      Destination Address                      |
    /// +                          (128 bits)                           +
    /// |                                                               |
    /// +                                                               +
    /// |                                                               |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// ```
    public struct Header: Sendable, Hashable {
        /// Traffic Class (8 bits)
        public let trafficClass: TrafficClass

        /// Flow Label (20 bits)
        public let flowLabel: FlowLabel

        /// Payload Length (16 bits)
        ///
        /// Length of the payload in octets, including extension headers.
        /// Maximum value is 65535.
        public let payloadLength: UInt16

        /// Next Header (8 bits)
        ///
        /// Identifies the type of header immediately following.
        public let nextHeader: NextHeader

        /// Hop Limit (8 bits)
        ///
        /// Decremented by 1 by each forwarding node.
        /// Packet is discarded when limit reaches 0.
        public let hopLimit: UInt8

        /// Source Address (128 bits)
        public let source: RFC_4291.IPv6.Address

        /// Destination Address (128 bits)
        public let destination: RFC_4291.IPv6.Address

        /// Creates an IPv6 header
        public init(
            trafficClass: TrafficClass = .default,
            flowLabel: FlowLabel = .zero,
            payloadLength: UInt16,
            nextHeader: NextHeader,
            hopLimit: UInt8,
            source: RFC_4291.IPv6.Address,
            destination: RFC_4291.IPv6.Address
        ) {
            self.trafficClass = trafficClass
            self.flowLabel = flowLabel
            self.payloadLength = payloadLength
            self.nextHeader = nextHeader
            self.hopLimit = hopLimit
            self.source = source
            self.destination = destination
        }
    }
}

extension RFC_8200.Header: Binary.Serializable {
    /// Serializes the IPv6 header to wire format (40 bytes)
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ header: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.reserveCapacity(buffer.count + 40)

        let version: UInt8 = 6
        let tc = header.trafficClass.rawValue
        let fl = header.flowLabel.rawValue

        buffer.append(Byte((version << 4) | (tc >> 4)))

        buffer.append(Byte(((tc & 0x0F) << 4) | UInt8((fl >> 16) & 0x0F)))

        buffer.append(Byte(UInt8((fl >> 8) & 0xFF)))
        buffer.append(Byte(UInt8(fl & 0xFF)))

        buffer.append(contentsOf: header.payloadLength.bytes(endianness: .big))

        buffer.append(Byte(header.nextHeader.rawValue))

        buffer.append(Byte(header.hopLimit))

        RFC_4291.IPv6.Address.serialize(header.source, into: &buffer)

        RFC_4291.IPv6.Address.serialize(header.destination, into: &buffer)
    }

    /// Parses an IPv6 header from wire format bytes
    ///
    /// - Parameter bytes: At least 40 bytes
    /// - Throws: `Error` if bytes are malformed
    public init<Bytes: Swift::Collection>(binary bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count >= 40 else {
            throw Error.invalidLength(bytes.count)
        }

        var iterator = bytes.makeIterator()

        func next() -> UInt8 {
            iterator.next()!.bitPattern
        }

        let byte0 = next()
        let byte1 = next()
        let byte2 = next()
        let byte3 = next()

        let version = (byte0 >> 4) & 0x0F
        guard version == 6 else {
            throw Error.invalidVersion(version)
        }

        let tc = ((byte0 & 0x0F) << 4) | ((byte1 >> 4) & 0x0F)
        self.trafficClass = RFC_8200.TrafficClass(rawValue: tc)

        let fl = (UInt32(byte1 & 0x0F) << 16) | (UInt32(byte2) << 8) | UInt32(byte3)
        self.flowLabel = RFC_8200.FlowLabel(rawValue: fl)

        let pl0 = next()
        let pl1 = next()
        self.payloadLength = (UInt16(pl0) << 8) | UInt16(pl1)

        self.nextHeader = RFC_8200.NextHeader(rawValue: next())

        self.hopLimit = next()

        var sourceBytes: [Byte] = []
        sourceBytes.reserveCapacity(16)
        for _ in 0..<16 {
            sourceBytes.append(Byte(next()))
        }
        do throws(RFC_4291.IPv6.Address.Error) {
            self.source = try RFC_4291.IPv6.Address(binary: sourceBytes)
        } catch {
            throw Error.invalidSourceAddress(error)
        }

        var destBytes: [Byte] = []
        destBytes.reserveCapacity(16)
        for _ in 0..<16 {
            destBytes.append(Byte(next()))
        }
        do throws(RFC_4291.IPv6.Address.Error) {
            self.destination = try RFC_4291.IPv6.Address(binary: destBytes)
        } catch {
            throw Error.invalidDestinationAddress(error)
        }
    }
}
