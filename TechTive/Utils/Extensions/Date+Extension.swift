import Foundation

extension Date {
    /**
     This `Date` in the format "M/d/yyyy".
     For example, 12/25/23 8:00 PM is 12/25/23.
     */
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter.string(from: self)
    }

    /**
     This `Date` in the format "MM/dd h:mm a".
     For example, 12/25/23 8:00 PM is 12/25 8:00 PM.
     */
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd h:mm a"
        return formatter.string(from: self)
    }

    /**
     This `Date` in the format "h:mm a".
     For example, 12/25/23 8:00 PM is 8:00 PM.
     */
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    /**
     This `Date` in the format "h:mm a" with trailing 00 removed.
     For example, 8:00 PM is 8 PM.
     */
    var timeStringNoTrailingZeros: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        // Remove trailing 00
        let formatted = formatter.string(from: self)
        if formatted.hasSuffix("00 AM") || formatted.hasSuffix("00 PM"),
           let colonPos = formatted.firstIndex(of: ":"),
           let spacePos = formatted.firstIndex(of: " ")
        {
            let first = formatted[..<colonPos]
            let last = formatted[formatted.index(spacePos, offsetBy: 0)...]
            return String(first + last)
        }

        return formatted
    }

    /**
     This `Date` in the format "ha".
     For example, 8:00 PM is 8PM.
     */
    var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: self)
    }

    /**
     This `Date` in the format "EEEE, MMMM dd".
     For example, 4/29/24 8:00 PM is Monday, April 29.
     */
    var dateStringDayMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        return dateFormatter.string(from: self)
    }

    /// Returns a date string in the localized short date style
    var localizedShortDate: String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }

    /// Returns whether this date is the same day as the given date
    func isSameDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let thisDate = calendar.dateComponents([.year, .month, .day], from: self)
        let otherDate = calendar.dateComponents([.year, .month, .day], from: date)
        return thisDate.month == otherDate.month && thisDate.day == otherDate.day
    }

    /// Creates a Date object from a string with the specified format
    static func fromString(_ dateString: String, format: String = "EEE MMM dd, yyyy") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }

    /// Returns the start of the week for this date
    var startOfWeek: Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
