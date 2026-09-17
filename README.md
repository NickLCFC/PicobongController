# PicobongController

SwiftUI iOS app (iOS 14+) for discovering and controlling supported Picobong BLE devices.

## Features

- BLE discovery for supported Picobong names from Buttplug config
- Connect / disconnect device control
- Vibration intensity control (0-100%) and turn-off action
- MVVM state management for Bluetooth/device state updates

## Supported Picobong Device Names

- Blow hole
- Diver
- Picobong Egg
- Life guard
- Picobong Ring
- Surfer
- Picobong Butt Plug
- Egg driver
- Surfer_plug

## BLE Protocol Details

- Protocol: `picobong`
- Service UUID: `0000fff0-0000-1000-8000-00805f9b34fb`
- TX Characteristic UUID: `0000fff1-0000-1000-8000-00805f9b34fb`
