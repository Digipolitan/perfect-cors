# perfect-cors-swift

[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

Perfect CORS is a swift package for providing a middleware that can be used to enable [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) with various options

## Installation

### Swift Package Manager

To install PerfectCORS with SPM, add the following lines to your `Package.swift`.

```swift
import PackageDescription

let package = Package(
    name: "XXX",
    dependencies: [
        .Package(url: "https://github.com/Digipolitan/perfect-cors-swift.git", majorVersion: 1)
    ]
)
```

## Usage

### Simple Usage (Enable *All* CORS Requests)

```swift
let server = HTTPServer()

let router = RouterMiddleware()

router.use(event: .beforeAll, middleware: CORS())

router.get(path: "/products").bind { context in
    try context.response.setBody(json: [
        "msg": "This is CORS-enabled for all origins!"
    ])
    context.next()
 }

server.use(router: router)

server.serverPort = 8080

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```

### Enable CORS for a Single Route

```swift
let server = HTTPServer()

let router = RouterMiddleware()

router.get(path: "/products").bind(CORS()).bind { context in
    try context.response.setBody(json: [
        "This is CORS-enabled for a Single Route"
    ])
    context.next()
 }

server.use(router: router)

server.serverPort = 8080

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```

### Configuring CORS

```swift
let server = HTTPServer()

let router = RouterMiddleware()

let options = CORS.Options(origin: ["http://example.com"], optionsSuccess: .ok)

router.get(path: "/products").bind(CORS(options: options)).bind { context in
    try context.response.setBody(json: [
        "This is CORS-enabled for only example.com"
    ])
    context.next()
 }

server.use(router: router)

server.serverPort = 8080

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```

## Configuration Options


| Property | type | Description  |
| --- | --- | --- |
| origin | `[String]` | Configures the **Access-Control-Allow-Origin** CORS header, set `origin` to an array of valid origins. Each origin can be a `String`. For example `["http://example1.com", "http://example2.com"]` will accept any request from "http://example1.com" or from "http://example2.com" |
| methods | `[HTTPMethod]` | Configures the **Access-Control-Allow-Methods** CORS header |
| allowedHeaders | `HTTPRequestHeader.Name` | Configures the **Access-Control-Allow-Headers** CORS header. If not specified, defaults to reflecting the headers specified in the request's **Access-Control-Request-Headers** header. |
| exposedHeaders | `HTTPResponseHeader.Name` | Configures the **Access-Control-Expose-Headers** CORS header. If not specified, no custom headers are exposed. |
| credentials | `Bool` | Configures the **Access-Control-Allow-Credentials** CORS header. Set to `true` to pass the header, otherwise it is omitted. |
| maxAge | `Double` | Configures the **Access-Control-Max-Age** CORS header. Set to a double to pass the header, otherwise it is omitted. |
| preflightContinue | `Bool` | Pass the CORS preflight response to the next handler. |
| optionsSuccessStatus | `HTTPResponseStatus` | Provides a status code to use for successful `OPTIONS` requests, since some legacy browsers (IE11, various SmartTVs) choke on `204` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

PerfectCORS is licensed under the [BSD 3-Clause license](LICENSE).
