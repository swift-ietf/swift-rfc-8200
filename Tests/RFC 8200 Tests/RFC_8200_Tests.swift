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

@Suite("RFC 8200 IPv6 Packet Tests")
struct RFC8200Tests {

    @Suite("Constants Tests")
    struct ConstantsTests {
        @Test
        func `Version is 6`() {
            #expect(RFC_8200.version == 6)
        }

        @Test
        func `Header size is 40 bytes`() {
            #expect(RFC_8200.headerSize == 40)
        }
    }

    @Suite("NextHeader Tests")
    struct NextHeaderTests {
        @Test
        func `Extension header values`() {
            #expect(RFC_8200.NextHeader.hopByHop.rawValue == 0)
            #expect(RFC_8200.NextHeader.routing.rawValue == 43)
            #expect(RFC_8200.NextHeader.fragment.rawValue == 44)
            #expect(RFC_8200.NextHeader.esp.rawValue == 50)
            #expect(RFC_8200.NextHeader.ah.rawValue == 51)
            #expect(RFC_8200.NextHeader.destinationOptions.rawValue == 60)
        }

        @Test
        func `Upper layer protocol values`() {
            #expect(RFC_8200.NextHeader.tcp.rawValue == 6)
            #expect(RFC_8200.NextHeader.udp.rawValue == 17)
            #expect(RFC_8200.NextHeader.icmpv6.rawValue == 58)
            #expect(RFC_8200.NextHeader.noNextHeader.rawValue == 59)
        }

        @Test
        func `Extension header classification`() {
            #expect(RFC_8200.NextHeader.hopByHop.isExtensionHeader == true)
            #expect(RFC_8200.NextHeader.fragment.isExtensionHeader == true)
            #expect(RFC_8200.NextHeader.tcp.isExtensionHeader == false)
            #expect(RFC_8200.NextHeader.udp.isExtensionHeader == false)
        }

        @Test
        func `Upper layer classification`() {
            #expect(RFC_8200.NextHeader.tcp.isUpperLayerProtocol == true)
            #expect(RFC_8200.NextHeader.udp.isUpperLayerProtocol == true)
            #expect(RFC_8200.NextHeader.hopByHop.isUpperLayerProtocol == false)
            #expect(RFC_8200.NextHeader.noNextHeader.isUpperLayerProtocol == false)
        }
    }

    @Suite("TrafficClass Tests")
    struct TrafficClassTests {
        @Test
        func `Default is zero`() {
            #expect(RFC_8200.TrafficClass.default.rawValue == 0)
        }

        @Test
        func `DSCP and ECN extraction`() {
            let tc = RFC_8200.TrafficClass(dscp: 46, ecn: 2)
            #expect(tc.dscp == 46)
            #expect(tc.ecn == 2)
        }

        @Test
        func `Expedited Forwarding`() {
            #expect(RFC_8200.TrafficClass.ef.dscp == 46)
        }
    }

    @Suite("FlowLabel Tests")
    struct FlowLabelTests {
        @Test
        func `Zero flow label`() {
            #expect(RFC_8200.FlowLabel.zero.rawValue == 0)
        }

        @Test
        func `Max flow label is 20 bits`() {
            #expect(RFC_8200.FlowLabel.max.rawValue == 0xFFFFF)
        }

        @Test
        func `Values are masked to 20 bits`() {
            let fl = RFC_8200.FlowLabel(rawValue: 0xFFFFFFFF)
            #expect(fl.rawValue == 0xFFFFF)
        }
    }

    @Suite("Header Tests")
    struct HeaderTests {
        @Test
        func `Create basic header`() {
            let header = RFC_8200.Header(
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
            let header = RFC_8200.Header(
                trafficClass: .default,
                flowLabel: .zero,
                payloadLength: 0,
                nextHeader: .tcp,
                hopLimit: 64,
                source: .loopback,
                destination: .loopback
            )

            var buffer: [UInt8] = []
            RFC_8200.Header.serialize(header, into: &buffer)

            #expect(buffer.count == 40)
        }

        @Test
        func `Version field is 6`() {
            let header = RFC_8200.Header(
                payloadLength: 0,
                nextHeader: .tcp,
                hopLimit: 64,
                source: .loopback,
                destination: .loopback
            )

            var buffer: [UInt8] = []
            RFC_8200.Header.serialize(header, into: &buffer)

            let version = (buffer[0] >> 4) & 0x0F
            #expect(version == 6)
        }

        @Test
        func `Serialization round-trip`() throws {
            let original = RFC_8200.Header(
                trafficClass: RFC_8200.TrafficClass(dscp: 10, ecn: 1),
                flowLabel: RFC_8200.FlowLabel(rawValue: 0x12345),
                payloadLength: 1024,
                nextHeader: .udp,
                hopLimit: 128,
                source: RFC_4291.IPv6.Address(0x2001, 0xdb8, 0, 0, 0, 0, 0, 1),
                destination: RFC_4291.IPv6.Address(0x2001, 0xdb8, 0, 0, 0, 0, 0, 2)
            )

            var buffer: [UInt8] = []
            RFC_8200.Header.serialize(original, into: &buffer)

            let parsed = try RFC_8200.Header(binary: buffer)

            #expect(parsed.trafficClass == original.trafficClass)
            #expect(parsed.flowLabel == original.flowLabel)
            #expect(parsed.payloadLength == original.payloadLength)
            #expect(parsed.nextHeader == original.nextHeader)
            #expect(parsed.hopLimit == original.hopLimit)
            #expect(parsed.source == original.source)
            #expect(parsed.destination == original.destination)
        }

        @Test
        func `Reject short buffer`() {
            let shortBuffer: [UInt8] = Array(repeating: 0, count: 39)

            #expect(throws: RFC_8200.Header.Error.self) {
                try RFC_8200.Header(binary: shortBuffer)
            }
        }

        @Test
        func `Reject wrong version`() {
            var buffer: [UInt8] = Array(repeating: 0, count: 40)
            buffer[0] = 0x40 // Version 4 instead of 6

            #expect(throws: RFC_8200.Header.Error.self) {
                try RFC_8200.Header(binary: buffer)
            }
        }
    }

    @Suite("Fragment Header Tests")
    struct FragmentHeaderTests {
        @Test
        func `Create fragment header`() {
            let fragment = RFC_8200.Extension.Fragment(
                nextHeader: .tcp,
                fragmentOffset: 100,
                moreFragments: true,
                identification: 0x12345678
            )

            #expect(fragment.nextHeader == .tcp)
            #expect(fragment.fragmentOffset == 100)
            #expect(fragment.moreFragments == true)
            #expect(fragment.identification == 0x12345678)
        }

        @Test
        func `Serialize fragment header to 8 bytes`() {
            let fragment = RFC_8200.Extension.Fragment(
                nextHeader: .tcp,
                fragmentOffset: 0,
                moreFragments: false,
                identification: 0
            )

            var buffer: [UInt8] = []
            RFC_8200.Extension.Fragment.serialize(fragment, into: &buffer)

            #expect(buffer.count == 8)
        }
    }
}
