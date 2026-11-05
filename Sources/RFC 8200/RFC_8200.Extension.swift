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

// RFC_8200.Extension.swift
// swift-rfc-8200
//
// RFC 8200 Section 4: IPv6 Extension Headers

public import Binary
public import Byte

extension RFC_8200 {
    /// Extension headers namespace
    ///
    /// IPv6 extension headers provide optional internet-layer information
    /// and are placed between the IPv6 header and the upper-layer header.
    ///
    /// ## Extension Header Order
    ///
    /// Per RFC 8200 Section 4.1, extension headers should appear in this order:
    /// 1. IPv6 header
    /// 2. Hop-by-Hop Options header
    /// 3. Destination Options header (for first destination)
    /// 4. Routing header
    /// 5. Fragment header
    /// 6. Authentication header
    /// 7. Encapsulating Security Payload header
    /// 8. Destination Options header (for final destination)
    /// 9. Upper-layer header
    public enum Extension {}
}

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
            self.fragmentOffset = fragmentOffset & 0x1FFF  // 13 bits max
            self.moreFragments = moreFragments
            self.identification = identification
        }
    }
}

extension RFC_8200.Extension.Fragment: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ fragment: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        // Byte 0: Next Header. NextHeader.rawValue stays UInt8 (separate
        // file out of arc scope); bridge via Byte() at the boundary.
        buffer.append(Byte(fragment.nextHeader.rawValue))

        // Byte 1: Reserved
        buffer.append(Byte(0))

        // Bytes 2-3: Fragment Offset (13 bits) | Res (2 bits) | M flag (1 bit)
        // UInt16 arithmetic-domain via Byte-primary bytes(endianness:).
        var offsetFlags = fragment.fragmentOffset << 3
        if fragment.moreFragments {
            offsetFlags |= 0x0001
        }
        buffer.append(contentsOf: offsetFlags.bytes(endianness: .big))

        // Bytes 4-7: Identification (UInt32 arithmetic-domain) via Byte-primary
        // BinaryInteger.bytes(endianness:).
        buffer.append(contentsOf: fragment.identification.bytes(endianness: .big))
    }
}
