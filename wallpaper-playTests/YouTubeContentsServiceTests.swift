import XCTest
@testable import Wallpaper_Play

class YouTubeContentsServiceTests: XCTestCase {
    var subject: YouTubeContentsServiceImpl!

    override func setUpWithError() throws {
        subject = .init(injector: testInjector)
    }

    func testBuildFullIframeUrlOnNormally() throws {
        let result = subject.buildFullIframeUrl(id: "1234", mute: true)
        XCTAssertEqual(result, URL(string: "https://www.youtube.com/embed/1234?playlist=1234&mute=1&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0")!)
    }

    func testBuildFullIframeUrlWhenMuteIsTrue() throws {
        let result = subject.buildFullIframeUrl(id: "mute", mute: true)
        XCTAssertEqual(result, URL(string: "https://www.youtube.com/embed/mute?playlist=mute&mute=1&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0")!)
    }

    func testBuildFullIframeUrlWhenMuteIsFalse() throws {
        let result = subject.buildFullIframeUrl(id: "unmute", mute: false)
        XCTAssertEqual(result, URL(string: "https://www.youtube.com/embed/unmute?playlist=unmute&mute=0&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0")!)
    }

    func testBuildThumbnailUrl() throws {
        let result = subject.buildThumbnailUrl(id: "1234", quality: .default)
        XCTAssertEqual(result, URL(string: "https://img.youtube.com/vi/1234/default.jpg")!)
    }

    func testReplaceMutedIframeUrl() throws {
        let url = URL(string: "https://www.youtube.com/embed/1234?playlist=1234&mute=0&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0")!
        let result = subject.replaceMutedIframeUrl(url: url)
        XCTAssertEqual(result, URL(string: "https://www.youtube.com/embed/1234?playlist=1234&mute=1&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0")!)
    }

    func testGetInfo() throws {
        let result = subject.getInfo(embedLink: "https://www.youtube.com/embed/1234?playlist=1234&mute=1&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0")
        XCTAssertEqual(result?.videoId, "1234")
        XCTAssertEqual(result?.isMute, true)
    }

    func testGetInfoWhenLinkIsNotYouTube() throws {
        let result = subject.getInfo(embedLink: "https://www.google.com")
        XCTAssertNil(result)
    }

    func testGetVideoId() throws {
        let result = subject.getVideoId(youtubeLink: "https://www.youtube.com/watch?v=1234")
        XCTAssertEqual(result, "1234")
    }

    func testGetVideoIdWhenLinkIsNotYouTube() throws {
        let result = subject.getVideoId(youtubeLink: "https://www.google.com")
        XCTAssertNil(result)
    }

    func testIsYouTubeDomain() throws {
        XCTAssertTrue(subject.isYouTubeDomain(link: "https://www.youtube.com/watch?v=1234"))
    }

    func testIsYouTubeDomainWhenLinkIsNotYouTube() throws {
        XCTAssertFalse(subject.isYouTubeDomain(link: "https://www.google.com"))
    }
}
