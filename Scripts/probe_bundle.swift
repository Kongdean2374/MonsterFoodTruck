import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: probe_bundle.swift /absolute/path/to/App.app\n", stderr)
    exit(2)
}
let url = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let bundle = Bundle(url: url)
let identifier = bundle?.bundleIdentifier
print("Foundation.Bundle path: \(url.path)")
print("Foundation.Bundle identifier: \(identifier ?? "<nil>")")
guard identifier == "cc.chaihome.monsterfoodtruck", bundle?.executableURL != nil else {
    fputs("Built app is not readable as the expected application bundle by Foundation.\n", stderr)
    exit(1)
}
