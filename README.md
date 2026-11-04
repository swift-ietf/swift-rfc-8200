# swift-rfc-8200

Use this package when you need to read or write the fixed 40-byte header of an IPv6 packet, or write a Fragment extension header. Start from `RFC_8200.Header`. For IPv4 packets, use swift-rfc-791. For the IPv6 address type itself, use swift-rfc-4291.

## Laws

- Decoding a header needs at least 40 bytes and a version field of 6. Anything else is refused.
- Decoding reads only the first 40 bytes. The bytes after them, such as extension headers and payload, are left alone and are not checked against the payload length.
- Fields wider than the wire format are cut to fit rather than refused. A flow label keeps its low 20 bits, so `0xFFFF_FFFF` becomes `0xFFFFF`. A fragment offset keeps its low 13 bits, a DSCP its low 6 bits and an ECN value its low 2 bits.
- `RFC_8200.NextHeader.isUpperLayerProtocol` is true for every value that isn't a known extension header or No Next Header, including values with no assigned protocol.
