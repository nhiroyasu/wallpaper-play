import SwiftUI

struct AboutView: View {
    let imageSize: CGFloat = 128
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image("AppIcon_Vec")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize, alignment: .center)
            Text("Wallpaper Play")
                .font(.system(size: 18, weight: .medium, design: .default))
            Text("© Hiroyasu Niitsuma")
                .font(.system(size: 14, weight: .medium, design: .default))
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 600, height: 400, alignment: .center)
    }
}
