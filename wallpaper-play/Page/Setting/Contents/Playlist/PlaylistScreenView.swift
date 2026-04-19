import AVFoundation
import SwiftUI

struct PlaylistScreenView: View {
    @StateObject var vm: PlaylistViewModelImpl
    @State private var isPresentedDeleteAlert: Bool = false
    @State private var deleteTarget: Playlist?

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(vm.playlists, id: \.id) { playlist in
                        HStack(spacing: 12) {
                            PlaylistThumbnailView(url: playlist.videos.first?.url)
                                .frame(width: 112, height: 63)
                                .clipped()
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(playlist.name)
                                    .font(.system(size: 15, weight: .semibold))
                                Label("\(playlist.videos.count)", systemImage: "video")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 10) {
                                Button {
                                    vm.didTapPlayPlaylistButton(id: playlist.id)
                                } label: {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .buttonStyle(.borderless)
                                .controlSize(.regular)
                                .help("Play")

                                Button {
                                    vm.didTapEditPlaylistButton(playlist: playlist)
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .buttonStyle(.borderless)
                                .controlSize(.regular)
                                .help("Edit")

                                Button {
                                    deleteTarget = playlist
                                    isPresentedDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                                .controlSize(.regular)
                                .help("Delete")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    HStack {
                        Text("Playlists")
                        Spacer()
                        Button {
                            vm.didTapAddPlaylistButton()
                        } label: {
                            Label {
                                Text("Add Playlist")
                            } icon: {
                                Image(systemName: "plus")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .font(.headline)
                    .padding()
                }
            }
            .listStyle(.inset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            vm.fetchPlaylists()
        }
        .alert(isPresented: $vm.isPresentedAlert) {
            Alert(
                title: Text("Error"),
                message: Text(vm.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $isPresentedDeleteAlert) {
            Alert(
                title: Text("Delete Playlist"),
                message: Text("Are you sure you want to delete this playlist?"),
                primaryButton: .destructive(Text("Delete")) {
                    guard let deleteTarget else { return }
                    Task {
                        await vm.deletePlaylist(id: deleteTarget.id)
                    }
                    self.deleteTarget = nil
                },
                secondaryButton: .cancel {
                    deleteTarget = nil
                }
            )
        }
    }
}

private struct PlaylistThumbnailView: View {
    let url: URL?
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
            guard let url else { return }
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
