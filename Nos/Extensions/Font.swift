import SwiftUI

// https://stackoverflow.com/a/74416073
extension Font {
    static func clarity(_ fontWeight: UIFont.Weight, textStyle: UIFont.TextStyle = .body) -> Font {
        switch fontWeight {
        case .regular:
            clarityRegular(textStyle)
        case .medium:
            clarityMedium(textStyle)
        case .semibold:
            claritySemibold(textStyle)
        case .bold:
            clarityBold(textStyle)
        default:
            clarityRegular(textStyle)
        }
    }

    static func clarityRegular(_ textStyle: UIFont.TextStyle) -> Font {
        .custom("ClarityCity-Regular", size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
    }

    static func clarityMedium(_ textStyle: UIFont.TextStyle) -> Font {
        .custom("ClarityCity-Medium", size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
    }

    static func claritySemibold(_ textStyle: UIFont.TextStyle) -> Font {
        .custom("ClarityCity-SemiBold", size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
    }

    static func clarityBold(_ textStyle: UIFont.TextStyle) -> Font {
        .custom("ClarityCity-Bold", size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
    }

    static var clarityCaption = Font
        .custom("ClarityCity-Regular", size: UIFont.preferredFont(
            forTextStyle: .caption1
        ).pointSize)
    
    static var clarityCaption2 = Font
        .custom("ClarityCity-Regular", size: UIFont.preferredFont(
            forTextStyle: .caption2
        ).pointSize)
    
    static var claritySubheadline = clarity(.medium, textStyle: .subheadline)

    static var claritySemiBoldSubheadline = Font
        .custom("ClarityCity-SemiBold", size: UIFont.preferredFont(
            forTextStyle: .subheadline
        ).pointSize)

    static var brand = Font
        .custom("ClarityCity-Regular", size: UIFont.preferredFont(
            forTextStyle: .body
        ).pointSize)
}

extension UIFont {
    static var clarity = UIFont(
        name: "ClarityCity-Regular",
        size: UIFont.preferredFont(forTextStyle: .body).pointSize
    )!
}

// swiftlint:disable identifier_name
func PlainText(_ content: any StringProtocol) -> SwiftUI.Text {
    SwiftUI.Text(content)
}

func PlainText(_ localizedStringResource: LocalizedStringResource) -> SwiftUI.Text {
    SwiftUI.Text(localizedStringResource)
}

func BrandText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brand)
}
// swiftlint:enable identifier_name
