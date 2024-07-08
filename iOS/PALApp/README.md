### Dev history

In UserDevice, wanted to store the type of wearable device.
Started with this enum to represent the device type
```
enum UserDeviceType: Codable  {
    case Wearable(WearableDevice.Type)
    case LocalMicrophone
    case AppleWatch
}
```
But the associated value WearableDevice.Type is not codable.
There would be ways to make it (e.g. [Making a codable wrapper for metatypes, will I get into trouble by doing this? - Using Swift - Swift Forums](https://forums.swift.org/t/making-a-codable-wrapper-for-metatypes-will-i-get-into-trouble-by-doing-this/50060)) but not sure how safe it is (and it makes hardcodes the class name in the DB).
An alternative is to have the WearableDevice return a name or identifier that can be used as a reference.
To make that work more cleaning, make the responsability of managing a wearable registry more explicit than an array in BLEManager.
