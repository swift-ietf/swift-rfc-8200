// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// RFC_8200.Header.swift
// swift-rfc-8200
//
// RFC 8200 Section 3: IPv6 Header Format

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

// MARK: - Binary.Serializable

extension RFC_8200.Header: Binary.Serializable {
    /// Serializes the IPv6 header to wire format (40 bytes)
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ header: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.reserveCapacity(buffer.count + 40)

        // First 4 bytes: Version (4) | Traffic Class (8) | Flow Label (20)
        // Version is always 6. Internal arithmetic-domain UInt8/UInt32
        // bitwise calculation; Byte() bridge at the buffer.append boundary.
        let version: UInt8 = 6
        let tc = header.trafficClass.rawValue
        let fl = header.flowLabel.rawValue

        // Byte 0: Version (4 bits) | Traffic Class high 4 bits
        buffer.append(Byte((version << 4) | (tc >> 4)))

        // Byte 1: Traffic Class low 4 bits | Flow Label high 4 bits
        buffer.append(Byte(((tc & 0x0F) << 4) | UInt8((fl >> 16) & 0x0F)))

        // Bytes 2-3: Flow Label low 16 bits
        buffer.append(Byte(UInt8((fl >> 8) & 0xFF)))
        buffer.append(Byte(UInt8(fl & 0xFF)))

        // Bytes 4-5: Payload Length (UInt16 arithmetic-domain) via Byte-primary
        // BinaryInteger.bytes(endianness:).
        buffer.append(contentsOf: header.payloadLength.bytes(endianness: .big))

        // Byte 6: Next Header
        buffer.append(Byte(header.nextHeader.rawValue))

        // Byte 7: Hop Limit (arithmetic-domain UInt8, decremented per hop)
        buffer.append(Byte(header.hopLimit))

        // Bytes 8-23: Source Address (16 bytes)
        RFC_4291.IPv6.Address.serialize(header.source, into: &buffer)

        // Bytes 24-39: Destination Address (16 bytes)
        RFC_4291.IPv6.Address.serialize(header.destination, into: &buffer)
    }

    /// Parses an IPv6 header from wire format bytes
    ///
    /// - Parameter bytes: At least 40 bytes
    /// - Throws: `Error` if bytes are malformed
    public init<Bytes: Collection>(binary bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count >= 40 else {
            throw Error.invalidLength(bytes.count)
        }

        var iterator = bytes.makeIterator()

        // Internal arithmetic-domain UInt8 byte stream; bridge from Byte at
        // the conformance boundary via .underlying.
        func next() -> UInt8 {
            iterator.next()!.underlying
        }

        // First 4 bytes
        let byte0 = next()
        let byte1 = next()
        let byte2 = next()
        let byte3 = next()

        // Version (4 bits)
        let version = (byte0 >> 4) & 0x0F
        guard version == 6 else {
            throw Error.invalidVersion(version)
        }

        // Traffic Class (8 bits spanning bytes 0-1)
        let tc = ((byte0 & 0x0F) << 4) | ((byte1 >> 4) & 0x0F)
        self.trafficClass = RFC_8200.TrafficClass(rawValue: tc)

        // Flow Label (20 bits spanning bytes 1-3)
        let fl = (UInt32(byte1 & 0x0F) << 16) | (UInt32(byte2) << 8) | UInt32(byte3)
        self.flowLabel = RFC_8200.FlowLabel(rawValue: fl)

        // Payload Length (16 bits)
        let pl0 = next()
        let pl1 = next()
        self.payloadLength = (UInt16(pl0) << 8) | UInt16(pl1)

        // Next Header (8 bits)
        self.nextHeader = RFC_8200.NextHeader(rawValue: next())

        // Hop Limit (8 bits)
        self.hopLimit = next()

        // Source Address (128 bits / 16 bytes). Internal buffer typed [Byte]
        // for the byte-domain IPv6.Address(binary:) conformance.
        var sourceBytes: [Byte] = []
        sourceBytes.reserveCapacity(16)
        for _ in 0..<16 {
            sourceBytes.append(Byte(next()))
        }
        do {
            self.source = try RFC_4291.IPv6.Address(binary: sourceBytes)
        } catch {
            throw Error.invalidSourceAddress(error)
        }

        // Destination Address (128 bits / 16 bytes)
        var destBytes: [Byte] = []
        destBytes.reserveCapacity(16)
        for _ in 0..<16 {
            destBytes.append(Byte(next()))
        }
        do {
            self.destination = try RFC_4291.IPv6.Address(binary: destBytes)
        } catch {
            throw Error.invalidDestinationAddress(error)
        }
    }
}

// MARK: - Codable

extension RFC_8200.Header: Codable {
    private enum CodingKeys: String, CodingKey {
        case trafficClass
        case flowLabel
        case payloadLength
        case nextHeader
        case hopLimit
        case source
        case destination
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trafficClass = try container.decode(RFC_8200.TrafficClass.self, forKey: .trafficClass)
        self.flowLabel = try container.decode(RFC_8200.FlowLabel.self, forKey: .flowLabel)
        self.payloadLength = try container.decode(UInt16.self, forKey: .payloadLength)
        self.nextHeader = try container.decode(RFC_8200.NextHeader.self, forKey: .nextHeader)
        self.hopLimit = try container.decode(UInt8.self, forKey: .hopLimit)
        self.source = try container.decode(RFC_4291.IPv6.Address.self, forKey: .source)
        self.destination = try container.decode(RFC_4291.IPv6.Address.self, forKey: .destination)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trafficClass, forKey: .trafficClass)
        try container.encode(flowLabel, forKey: .flowLabel)
        try container.encode(payloadLength, forKey: .payloadLength)
        try container.encode(nextHeader, forKey: .nextHeader)
        try container.encode(hopLimit, forKey: .hopLimit)
        try container.encode(source, forKey: .source)
        try container.encode(destination, forKey: .destination)
    }
}
