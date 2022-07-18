import Foundation

struct URLContent {
    let path: String
    let queryItems: [URLQueryItem]
}


protocol URLResolverService {
    func resolve(_ url: URL) -> URLContent?
    func resolve(_ url: String) -> URLContent?
}

class URLResolverServiceImpl: URLResolverService {
    func resolve(_ url: URL) -> URLContent? {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
              let path = components.string,
              let queryItems = components.queryItems else {
            return nil
        }
        return URLContent(path: path, queryItems: queryItems)
    }
    
    func resolve(_ url: String) -> URLContent? {
        guard let url = URL(string: url) else { return nil }
        return resolve(url)
    }
}
