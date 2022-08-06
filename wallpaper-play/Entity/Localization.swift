import Foundation

enum LocalizationKey: String {
    case preference_launch_at_login_title
    case preference_display_icon_title
    case preference_open_window_title
    case preference_launch_at_login_description
    case preference_display_icon_description
    case preference_open_window_description

    case error_invalid_url
    case error_invalid_preview
    case error_invalid_video
    case error_invalid_youtube_url
    case error_common

    case term_of_use
    case term_of_use_link
    case privacy_policy
    case privacy_policy_link
}

func LocalizedString(key: LocalizationKey) -> String {
    NSLocalizedString(key.rawValue, comment: "")
}
