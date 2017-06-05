import PerfectMiddleware
import PerfectHTTP

/**
 * CORS is a middleware that can be used to enable CORS with various options
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
public class CORS: Middleware {

    /**
     * CORS Consts
     */
    public enum Consts {

        /**
         * Retrieves default Option configuration
         */
        public static let options: Options = Options()

        /**
         * Retrieves default methods authorized
         */
        public static let defaultMethods: [HTTPMethod] = [.get, .post, .put, .delete, .head, .custom("PATCH")]
        /**
         * Access control allow headers field
         */
        public static let accessControlAllowHeaders = HTTPResponseHeader.Name.custom(name: "Access-Control-Allow-Headers")
        /**
         * Access control expose headers field
         */
        public static let accessControlExposeHeaders = HTTPResponseHeader.Name.custom(name: "Access-Control-Expose-Headers")
    }

    /**
     * CORS options
     */
    public struct Options {

        /**
         * Configures the Access-Control-Allow-Origin CORS header
         */
        public let origin: [String]?

        /**
         * Configures the Access-Control-Allow-Methods CORS header
         * Default : Consts.defaultMethods
         */
        public let methods: [HTTPMethod]

        /**
         * Pass the CORS preflight response to the next handler
         * Default : false
         */
        public let preflightContinue: Bool

        /**
         * Provides a status code to use for successful OPTIONS requests
         * Default : .noContent
         */
        public let optionsSuccess: HTTPResponseStatus

        /**
         * Configures the Access-Control-Allow-Headers CORS header. If not specified, defaults to reflecting the headers specified in the request's Access-Control-Request-Headers header
         */
        public let allowedHeaders: [HTTPRequestHeader.Name]?

        /**
         * Configures the Access-Control-Expose-Headers CORS header. If not specified, no custom headers are exposed
         */
        public let exposedHeaders: [HTTPResponseHeader.Name]?

        /**
         * Configures the Access-Control-Max-Age CORS header. Set to an integer to pass the header, otherwise it is omitted
         */
        public let maxAge: Double?

        /**
         * Configures the Access-Control-Allow-Credentials CORS header. Set to true to pass the header, otherwise it is omitted
         */
        public let credentials: Bool?

        public init(origin: [String]? = nil,
                    methods: [HTTPMethod] = Consts.defaultMethods,
                    preflightContinue: Bool = false,
                    optionsSuccess: HTTPResponseStatus = .noContent,
                    allowedHeaders: [HTTPRequestHeader.Name]? = nil,
                    exposedHeaders: [HTTPResponseHeader.Name]? = nil,
                    maxAge: Double? = nil,
                    credentials: Bool? = nil) {
            self.origin = origin
            self.methods = methods
            self.preflightContinue = preflightContinue
            self.optionsSuccess = optionsSuccess
            self.allowedHeaders = allowedHeaders
            self.exposedHeaders = exposedHeaders
            self.maxAge = maxAge
            self.credentials = credentials
        }
    }

    private let options: Options

    /**
     * Creates a CORS object using Options
     */
    public init(options: Options = Consts.options) {
        self.options = options
    }

    /**
     * Handle the middleware
     * @param context The route context
     */
    public func handle(context: RouteContext) throws {
        let method = context.request.method
        let request = context.request
        let response = context.response
        if method == .options {
            self.configureOrigin(request: request, response: response)
            self.configureCredentials(request: request, response: response)
            self.configureMethods(request: request, response: response)
            self.configureAllowedHeaders(request: request, response: response)
            self.configureMaxAge(request: request, response: response)
            self.configureExposedHeaders(request: request, response: response)

            if !options.preflightContinue {
                response.completed(status: self.options.optionsSuccess)
            }
        } else {
            self.configureOrigin(request: request, response: response)
            self.configureCredentials(request: request, response: response)
            self.configureExposedHeaders(request: request, response: response)
        }

        context.next()
    }

    private func configureOrigin(request: HTTPRequest, response: HTTPResponse) {
        if let origin = self.options.origin {
            if let requestOrigin = request.header(.origin) {
                if origin.index(of: requestOrigin) != nil {
                    response.setHeader(.accessControlAllowOrigin, value: requestOrigin)
                    return
                }
            }
            response.setHeader(.accessControlAllowOrigin, value: "false")
            return
        }
        response.setHeader(.accessControlAllowOrigin, value: "*")
    }

    private func configureCredentials(request: HTTPRequest, response: HTTPResponse) {
        if let credentials = self.options.credentials {
            response.setHeader(.accessControlAllowCredentials, value: credentials == true ? "true" : "false")
        }
    }

    private func configureMethods(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.accessControlAllowMethods, value: self.options.methods.map { method -> String in
            return method.description
        }.joined(separator: ", "))
    }

    private func configureAllowedHeaders(request: HTTPRequest, response: HTTPResponse) {
        if let allowedHeaders = self.options.allowedHeaders {
            response.setHeader(Consts.accessControlAllowHeaders, value: allowedHeaders.map { header -> String in
                return header.standardName
              }.joined(separator: ", "))
        } else if let requestHeaders = request.header(.accessControlRequestHeaders) {
            response.setHeader(Consts.accessControlAllowHeaders, value: requestHeaders)
        }
    }

    private func configureMaxAge(request: HTTPRequest, response: HTTPResponse) {
        if let maxAge = self.options.maxAge {
            if maxAge > 0 {
                response.setHeader(.accessControlMaxAge, value: String(maxAge))
            }
        }
    }

    private func configureExposedHeaders(request: HTTPRequest, response: HTTPResponse) {
        if let exposeHeaders = self.options.exposedHeaders {
            response.setHeader(Consts.accessControlExposeHeaders, value: exposeHeaders.map { header -> String in
                return header.standardName
             }.joined(separator: ", "))
        }
    }
}
