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

import Testing
@testable import RFC_8200

enum `IETF.RFC.8200 Tests` {}

extension `IETF.RFC.8200 Tests` {
    @Suite
    struct `RFC 8200 IPv6 Packet Tests` {
    }
}

extension `IETF.RFC.8200 Tests`.`RFC 8200 IPv6 Packet Tests` {
    @Suite
    struct `Constants Tests` {
        @Test
        func `Version is 6`() {
            #expect(IETF.RFC.`8200`.version == 6)
        }

        @Test
        func `Header size is 40 bytes`() {
            #expect(IETF.RFC.`8200`.headerSize == 40)
        }
    }

    @Suite
    struct `NextHeader Tests` {
        @Test
        func `Extension header values`() {
            #expect(IETF.RFC.`8200`.NextHeader.hopByHop.rawValue == 0)
            #expect(IETF.RFC.`8200`.NextHeader.routing.rawValue == 43)
            #expect(IETF.RFC.`8200`.NextHeader.fragment.rawValue == 44)
            #expect(IETF.RFC.`8200`.NextHeader.esp.rawValue == 50)
            #expect(IETF.RFC.`8200`.NextHeader.ah.rawValue == 51)
            #expect(IETF.RFC.`8200`.NextHeader.destinationOptions.rawValue == 60)
        }

        @Test
        func `Upper layer protocol values`() {
            #expect(IETF.RFC.`8200`.NextHeader.tcp.rawValue == 6)
            #expect(IETF.RFC.`8200`.NextHeader.udp.rawValue == 17)
            #expect(IETF.RFC.`8200`.NextHeader.icmpv6.rawValue == 58)
            #expect(IETF.RFC.`8200`.NextHeader.noNextHeader.rawValue == 59)
        }

        @Test
        func `Extension header classification`() {
            #expect(IETF.RFC.`8200`.NextHeader.hopByHop.isExtensionHeader == true)
            #expect(IETF.RFC.`8200`.NextHeader.fragment.isExtensionHeader == true)
            #expect(IETF.RFC.`8200`.NextHeader.tcp.isExtensionHeader == false)
            #expect(IETF.RFC.`8200`.NextHeader.udp.isExtensionHeader == false)
        }

        @Test
        func `Upper layer classification`() {
            #expect(IETF.RFC.`8200`.NextHeader.tcp.isUpperLayerProtocol == true)
            #expect(IETF.RFC.`8200`.NextHeader.udp.isUpperLayerProtocol == true)
            #expect(IETF.RFC.`8200`.NextHeader.hopByHop.isUpperLayerProtocol == false)
            #expect(IETF.RFC.`8200`.NextHeader.noNextHeader.isUpperLayerProtocol == false)
        }
    }

    @Suite
    struct `TrafficClass Tests` {
        @Test
        func `Default is zero`() {
            #expect(IETF.RFC.`8200`.TrafficClass.default.rawValue == 0)
        }

        @Test
        func `DSCP and ECN extraction`() {
            let tc = IETF.RFC.`8200`.TrafficClass(dscp: 46, ecn: 2)
            #expect(tc.dscp == 46)
            #expect(tc.ecn == 2)
        }

        @Test
        func `Expedited Forwarding`() {
            #expect(IETF.RFC.`8200`.TrafficClass.ef.dscp == 46)
        }
    }

    @Suite
    struct `FlowLabel Tests` {
        @Test
        func `Zero flow label`() {
            #expect(IETF.RFC.`8200`.FlowLabel.zero.rawValue == 0)
        }

        @Test
        func `Max flow label is 20 bits`() {
            #expect(IETF.RFC.`8200`.FlowLabel.max.rawValue == 0xFFFFF)
        }

        @Test
        func `Values are masked to 20 bits`() {
            let fl = IETF.RFC.`8200`.FlowLabel(rawValue: 0xFFFF_FFFF)
            #expect(fl.rawValue == 0xFFFFF)
        }
    }

    @Suite
    struct `Header Tests` {
        @Test
        func `Create basic header`() {
            let header = IETF.RFC.`8200`.Header(
                trafficClass: .default,
                flowLabel: .zero,
                payloadLength: 100,
                nextHeader: .tcp,
                hopLimit: 64,
                source: .loopback,
                destination: .loopback
            )

            #expect(header.payloadLength == 100)
            #expect(header.nextHeader == .tcp)
            #expect(header.hopLimit == 64)
        }

        @Test
        func `Serialize to 40 bytes`() {
            let header = IETF.RFC.`8200`.Header(
                trafficClass: .default,
                flowLabel: .zero,
                payloadLength: 0,
                nextHeader: .tcp,
                hopLimit: 64,
                source: .loopback,
                destination: .loopback
            )

            var buffer: [Byte] = []
            IETF.RFC.`8200`.Header.serialize(header, into: &buffer)

            #expect(buffer.count == 40)
        }

        @Test
        func `Version field is 6`() {
            let header = IETF.RFC.`8200`.Header(
                payloadLength: 0,
                nextHeader: .tcp,
                hopLimit: 64,
                source: .loopback,
                destination: .loopback
            )

            var buffer: [Byte] = []
            IETF.RFC.`8200`.Header.serialize(header, into: &buffer)

            let version = (buffer[0].bitPattern >> 4) & 0x0F
            #expect(version == 6)
        }

        @Test
        func `Serialization round-trip`() throws {
            let original = IETF.RFC.`8200`.Header(
                trafficClass: IETF.RFC.`8200`.TrafficClass(dscp: 10, ecn: 1),
                flowLabel: IETF.RFC.`8200`.FlowLabel(rawValue: 0x12345),
                payloadLength: 1024,
                nextHeader: .udp,
                hopLimit: 128,
                source: IETF.RFC.`4291`.IPv6.Address(0x2001, 0xdb8, 0, 0, 0, 0, 0, 1),
                destination: IETF.RFC.`4291`.IPv6.Address(0x2001, 0xdb8, 0, 0, 0, 0, 0, 2)
            )

            var buffer: [Byte] = []
            IETF.RFC.`8200`.Header.serialize(original, into: &buffer)

            let parsed = try IETF.RFC.`8200`.Header(binary: buffer)

            #expect(parsed.trafficClass == original.trafficClass)
            #expect(parsed.flowLabel == original.flowLabel)
            #expect(parsed.payloadLength == original.payloadLength)
            #expect(parsed.nextHeader == original.nextHeader)
            #expect(parsed.hopLimit == original.hopLimit)
            #expect(parsed.source == original.source)
            #expect(parsed.destination == original.destination)
        }

        @Test
        func `Parse from offset slice with trailing payload`() throws {
            let original = IETF.RFC.`8200`.Header(
                trafficClass: IETF.RFC.`8200`.TrafficClass(dscp: 46, ecn: 2),
                flowLabel: IETF.RFC.`8200`.FlowLabel(rawValue: 0xABCDE),
                payloadLength: 8,
                nextHeader: .tcp,
                hopLimit: 64,
                source: IETF.RFC.`4291`.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
                destination: IETF.RFC.`4291`.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 2)
            )

            var buffer: [Byte] = Array(repeating: Byte(0xFF), count: 3)
            IETF.RFC.`8200`.Header.serialize(original, into: &buffer)
            buffer.append(contentsOf: Array(repeating: Byte(0xEE), count: 8))

            let parsed = try IETF.RFC.`8200`.Header(binary: buffer[3...])

            #expect(parsed == original)
        }

        @Test
        func `Reject short buffer`() {
            let shortBuffer: [Byte] = Array(repeating: Byte(0), count: 39)

            #expect(throws: IETF.RFC.`8200`.Header.Error.self) {
                try IETF.RFC.`8200`.Header(binary: shortBuffer)
            }
        }

        @Test
        func `Reject wrong version`() {
            var buffer: [Byte] = Array(repeating: Byte(0), count: 40)
            buffer[0] = Byte(0x40)  // Version 4 instead of 6

            #expect(throws: IETF.RFC.`8200`.Header.Error.self) {
                try IETF.RFC.`8200`.Header(binary: buffer)
            }
        }
    }

    @Suite
    struct `Fragment Header Tests` {
        @Test
        func `Create fragment header`() {
            let fragment = IETF.RFC.`8200`.Extension.Fragment(
                nextHeader: .tcp,
                fragmentOffset: 100,
                moreFragments: true,
                identification: 0x1234_5678
            )

            #expect(fragment.nextHeader == .tcp)
            #expect(fragment.fragmentOffset == 100)
            #expect(fragment.moreFragments == true)
            #expect(fragment.identification == 0x1234_5678)
        }

        @Test
        func `Serialize fragment header to 8 bytes`() {
            let fragment = IETF.RFC.`8200`.Extension.Fragment(
                nextHeader: .tcp,
                fragmentOffset: 0,
                moreFragments: false,
                identification: 0
            )

            var buffer: [Byte] = []
            IETF.RFC.`8200`.Extension.Fragment.serialize(fragment, into: &buffer)

            #expect(buffer.count == 8)
        }
    }
}
