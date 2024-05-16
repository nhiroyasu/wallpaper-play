const MENU_ID = 'wallpaper-play-for-youtube'


browser.contextMenus.create({
  id: MENU_ID,
  title: 'Set YouTube video as Wallpaper',
  contexts: ['all'],
  documentUrlPatterns: ['*://*.youtube.com/*'], // YouTubeのドメインに限定
  targetUrlPatterns: ['https://www.youtube.com/.*\bv=[w-]+'],
})

browser.contextMenus.onClicked.addListener(function (info, tab) {
  if (info.menuItemId === MENU_ID) {
    browser.storage.local.get('userSettings').then((result) => {
      if (!result.userSettings) {
        result.userSettings = {
          isMute: 'false',
        }
      }

      const isMute = result.userSettings.isMute
      if (checkYouTubeUrl(info.linkUrl)) {
        browser.tabs.create({
          url: buildUrlScheme(info.linkUrl, isMute),
        })
      } else if (checkYouTubeUrl(info.pageUrl)) {
        browser.tabs.create({
          url: buildUrlScheme(info.pageUrl, isMute),
        })
      } else {
        browser.tabs.query(
          { active: true, currentWindow: true },
          function (tabs) {
            browser.scripting.executeScript({
              target: { tabId: tabs[0].id },
              function: function () {
                alert('No video ID detected in the URL.')
              },
            })
          }
        )
        return
      }
    })
  }
})

function checkYouTubeUrl(url) {
  const pattern = /https:\/\/www\.youtube\.com\/.*\bv=[\w-]+/
  return pattern.test(url)
}

function buildUrlScheme(youtubeUrl, isMute) {
  const url = new URL('wallpaperplay://open')
  url.searchParams.set('youtube-url', youtubeUrl)
  url.searchParams.set('is-mute', isMute)
  return url.href
}
