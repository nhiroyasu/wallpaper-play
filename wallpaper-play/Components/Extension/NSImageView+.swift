import AppKit

extension NSImageView {
    func setImage(url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let mimeType = httpResponse.mimeType, mimeType.hasPrefix("image"),
                  let data = data else {
                DispatchQueue.main.async {
                    self.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
                }
                return
            }

            DispatchQueue.main.async {
                self.image = NSImage(data: data)
            }
        }
        task.resume()
    }
}
