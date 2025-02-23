import Foundation

protocol UrlValidationService {
    func validate(string: String) -> URL?
    func validateAsUrlSchema(url: URL) -> Bool 
}

class UrlValidationServiceImpl: UrlValidationService {
    func validate(string: String) -> URL? {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.?[a-z]{2,6}(:[0-9]{1,5})?(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: string)
        if result {
            return URL(string: string)
        } else {
            return nil
        }
    }

    func validateAsUrlSchema(url: URL) -> Bool {
        return url.scheme == "wallpaperplay"
    }
}
