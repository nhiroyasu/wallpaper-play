import SwiftUI

struct AboutView: View {
    let imageSize: CGFloat = 84

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image("AppIcon_Vec")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize, alignment: .center)
            Text("Wallpaper Play")
                .font(.system(size: 14, weight: .medium, design: .default))
            Link("© Hiroyasu Niitsuma", destination: URL(string: "https://nhiroyasu.com/")!)
            Link(
                LocalizedString(key: .term_of_use),
                destination: URL(string: LocalizedString(key: .term_of_use_link))!)
            Link(
                LocalizedString(key: .privacy_policy),
                destination: URL(string: LocalizedString(key: .privacy_policy_link))!)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 600, height: 400, alignment: .center)
    }
}
