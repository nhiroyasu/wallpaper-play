import AVFoundation
import SwiftUI

struct PlaylistFormScreenView: View {
    @StateObject var vm: PlaylistFormViewModelImpl

    var body: some View {
        ZStack {
            form
            if vm.isPresentedIndicator {
                indicator
            }
        }
        .frame(width: 600, height: 500)
        .alert(isPresented: $vm.isPresentedAlert) {
            Alert(
                title: Text("Error"),
                message: Text(vm.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    var form: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Playlist Form")
                    .font(.title3)
                    .bold()
                Spacer()
                Button {
                    vm.didTapCloseButton()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                Text("Name")
                    .font(.system(size: 13))
                TextField("Enter playlist name", text: $vm.playlistName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
            }

            Picker("Playback", selection: $vm.playbackMode) {
                ForEach(PlaylistPlaybackMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: 13))

            Picker("Video Size", selection: $vm.videoSize) {
                ForEach(VideoSize.allCases, id: \.self) { size in
                    Text(size.text).tag(size)
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: 13))

            if vm.videoSize == .aspectFit {
                ColorPicker("Background", selection: $vm.backgroundColor)
                    .font(.system(size: 13))
            }

            Picker("Display Target", selection: $vm.selectedDisplayTargetIndex) {
                ForEach(vm.displayTargetTitles.indices, id: \.self) { index in
                    Text(vm.displayTargetTitles[index]).tag(index)
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: 13))

            Toggle("Mute", isOn: $vm.isMute)
                .font(.system(size: 13))


            List {
                Section {
                    ForEach(vm.selectedFiles, id: \.self) { url in
                        HStack(spacing: 8) {
                            VideoThumbnailView(url: url)
                                .frame(width: 96, height: 54)
                                .clipped()
                                .cornerRadius(8)

                            Text(url.lastPathComponent)
                                .font(.system(size: 14))

                            Spacer()

                            Button {
                                vm.removeSelectedFile(url)
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .onMove { fromOffsets, toOffset in
                        vm.moveSelectedFiles(fromOffsets: fromOffsets, toOffset: toOffset)
                    }


                } header: {
                    HStack {
                        Text("Videos")
                            .font(.headline)
                        Spacer()
                        Button {
                            vm.pickVideoFiles()
                        } label: {
                            Label {
                                Text("Add Videos")
                            } icon: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.automatic)

            if #available(macOS 12.0, *) {
                Button {
                    Task {
                        await vm.savePlaylist()
                    }
                } label: {
                    Label {
                        Text(vm.saveButtonTitle)
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
                .disabled(!vm.canSave)
            } else {
                Button {
                    Task {
                        await vm.savePlaylist()
                    }
                } label: {
                    Label {
                        Text(vm.saveButtonTitle)
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                .controlSize(.large)
                .disabled(!vm.canSave)
            }
        }
        .padding(16)
    }

    var indicator: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(1.5)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.windowBackgroundColor).opacity(0.8))
            )
    }

}

private struct VideoThumbnailView: View {
    let url: URL
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
            }
        }
        .onAppear {
            Task {
                image = await loadThumbnail(url: url)
            }
        }
    }

    private func loadThumbnail(url: URL) async -> NSImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let generator = AVAssetImageGenerator(asset: AVAsset(url: url))
                if let cgImage = try? generator.copyCGImage(
                    at: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                    actualTime: nil
                ) {
                    continuation.resume(returning: NSImage(cgImage: cgImage, size: .zero))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
