document.addEventListener('DOMContentLoaded', function () {
  browser.storage.local.get("userSettings").then((result) => {
    if (!result.userSettings) {
      result.userSettings = {
        isMute: 'false',
      }
    }
    document.getElementById('mute-checkbox').checked = result.userSettings.isMute === 'true'
  })

  document.getElementById('download-button').addEventListener('click', () => {
    let url = 'https://apps.apple.com/jp/app/wallpaper-play/id1638457121'
    browser.tabs.create({ url })
  })

  document
    .getElementById('mute-checkbox')
    .addEventListener('change', async (event) => {
      const userSettings = {
        isMute: event.target.checked ? 'true' : 'false'
      }
      await browser.storage.local.set({ userSettings })
    })
})
