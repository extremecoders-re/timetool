import winim/inc/winbase
import json

# nim -d:release --opt:size c timetool.nim
import winim/com

# WarmUp
var obj = CreateObject("WinHttp.WinHttpRequest.5.1")
obj.open("get", "https://timeapi.io/api/Time/current/zone?timeZone=UTC")
obj.send()

echo "[+] Fetching current time"
obj = CreateObject("WinHttp.WinHttpRequest.5.1")
obj.open("get", "https://timeapi.io/api/Time/current/zone?timeZone=UTC")
obj.send()
let response_json = parseJson(obj.responseText)


#[
# nim -d:ssl -d:release --opt:size c timetool.nim
import httpclient

# WarmUp
var client = newHttpClient()
var response = client.get("https://timeapi.io/api/Time/current/zone?timeZone=Asia/Kolkata")

echo "[+] Fetching current time"
response = client.get("https://timeapi.io/api/Time/current/zone?timeZone=Asia/Kolkata")
let response_json = parseJson(response.body)
]#


var systemTime: SYSTEMTIME
systemTime.wYear = uint16(response_json["year"].getInt())
systemTime.wMonth = uint16(response_json["month"].getInt())
systemTime.wDay = uint16(response_json["day"].getInt())
systemTime.wHour = uint16(response_json["hour"].getInt())
systemTime.wMinute = uint16(response_json["minute"].getInt())
systemTime.wSecond = uint16(response_json["seconds"].getInt())
systemTime.wMilliseconds = uint16(response_json["milliSeconds"].getInt())
SetSystemTime(addr systemTime)

echo "[+] UTC Time set to: ", systemTime.wHour, ":", systemTime.wMinute, ":", systemTime.wSecond
