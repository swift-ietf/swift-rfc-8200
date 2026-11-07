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
}

extension RFC_8200.Extension {
}

extension RFC_8200.Extension.Fragment: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ fragment: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(Byte(fragment.nextHeader.rawValue))

        buffer.append(Byte(0))

        var offsetFlags = fragment.fragmentOffset << 3
        if fragment.moreFragments {
            offsetFlags |= 0x0001
        }
        buffer.append(contentsOf: offsetFlags.bytes(endianness: .big))

        buffer.append(contentsOf: fragment.identification.bytes(endianness: .big))
    }
}
