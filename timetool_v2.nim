import net
import nativesockets
import strformat

import winim/inc/windef
import winim/inc/winbase

# nim -d:release -d:strip --opt:size c timetool_v2.nim

# For cross compile
# nim -d:mingw -d:release -d:strip --opt:size c timetool_v2.nim

type
  NTP_PACKET{.packed.}  = object
    li_vn_mode: uint8      # Eight bits. li, vn, and mode.
                           # li.   Two bits.   Leap indicator.
                           # vn.   Three bits. Version number of the protocol.
                           # mode. Three bits. Client will pick mode 3 for client.

    stratum: uint8         # Eight bits. Stratum level of the local clock.
    poll: uint8 
    precision: uint8       # Eight bits. Precision of the local clock.

    rootDelay: uint32      # 32 bits. Total round trip delay time.
    rootDispersion: uint32 # 32 bits. Max error aloud from primary clock source.
    refId: uint32          # 32 bits. Reference clock identifier.

    refTm_s: uint32        # 32 bits. Reference time-stamp seconds.
    refTm_f: uint32        # 32 bits. Reference time-stamp fraction of a second.

    origTm_s: uint32       # 32 bits. Originate time-stamp seconds.
    origTm_f: uint32       # 32 bits. Originate time-stamp fraction of a second.

    rxTm_s: uint32         # 32 bits. Received time-stamp seconds.
    rxTm_f: uint32         # 32 bits. Received time-stamp fraction of a second.

    txTm_s: uint32         # 32 bits and the most important field the client cares about. Transmit time-stamp seconds.
    txTm_f: uint32         # 32 bits. Transmit time-stamp fraction of a second.


# Change to AF_INET6 for IPv6 only
const domain = Domain.AF_INET
let socket = newSocket(domain, SockType.SOCK_DGRAM, Protocol.IPPROTO_UDP)

var ntp_packet: NTP_PACKET
ntp_packet.li_vn_mode = 0x43

socket.sendTo("time.cloudflare.com", Port(123), ntp_packet.addr, sizeof(ntp_packet), domain)
discard socket.recv(ntp_packet.addr, sizeof(ntp_packet))

var txTimeSecs = ntohl(ntp_packet.txTm_s) - 2208988800'u32
var txTimeFracSecs = ntohl(ntp_packet.txTm_f)

var ns_intervals: uint64 = 116444736000000000'u64
ns_intervals += uint64(txTimeSecs) * 1_000_000_000 div 100
ns_intervals += (uint64(txTimeFracSecs) * 1_000_000 * 10) div 4294967296'u64

var filetime: FILETIME
var systemtime: SYSTEMTIME

filetime.dwLowDateTime = int32(ns_intervals and 0xFFFFFFFF'u64)
filetime.dwHighDateTime = int32(ns_intervals shr 32)

FileTimeToSystemTime(addr filetime, addr systemtime)
SetSystemTime(addr systemtime)

echo &"Time set to {systemtime.wHour}:{systemtime.wMinute}:{systemtime.wSecond}"
