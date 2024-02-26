## Email validations in Apply

We use the `ValidForNotifyValidator` class, which is a class designed to validate email addresses.

### Constants

- **NUMBERS_AND_LETTERS:** This constant represents a regular expression pattern for alphanumeric characters including English letters (both uppercase and lowercase) and digits.

- **CHINESE_JAPANESE_AND_KOREAN_CHARS:** Another regular expression pattern representing a range of characters commonly found in Chinese, Japanese, and Korean languages, along with various symbols. (see section below)

- **ALPHANUMERIC:** A combination of the above two patterns, representing a broader set of alphanumeric characters including Latin letters, digits, and characters from East Asian languages.

- **EMAIL_REGEX:** This constant defines a regular expression pattern for validating email addresses. It encompasses a wide range of characters including alphabets, digits, and special characters typically allowed in email addresses.

- **INVALID_EMAIL_REGEX_EDGE_CASES:** Another regular expression pattern that captures edge cases of invalid email addresses. It targets specific scenarios such as missing domain names, consecutive dots in the local part, and other anomalous patterns.

### Validations

**validate_each(record, attribute, value):**

- It takes three parameters:

1. `record` (the object being validated),
2. `attribute` (the attribute being validated),
3. and `value` (the value of the attribute).

If the value is blank, doesn't match the standard email pattern,
or matches any of the edge cases defined in `INVALID_EMAIL_REGEX_EDGE_CASES`,
it adds an error message to the record indicating an invalid email address format.

### Usage

To use this validator in any class, you can include it in your model class and
specify it for the desired attribute using the `validates` method:

```ruby
class User < ApplicationRecord
  validates :email_address, valid_for_notify: true
end
```

To include in the spec files:

```ruby
RSpec.describe User do
  it_behaves_like 'an email address valid for notify'
end
```

### International characters

Also there was a chinese/japanese/korean characters email constant that accepts:

\u3000-\u303F: This range represents CJK (Chinese, Japanese, and Korean) symbols and punctuation. It includes characters like
 ideographic space, ideographic comma, and other punctuation marks commonly used in CJK languages.

\u3040-\u309F: This range represents Hiragana characters, which are a Japanese syllabary used in native Japanese words and gr
ammatical elements.

\u30A0-\u30FF: This range represents Katakana characters, which are another Japanese syllabary used primarily for loanwords,
onomatopoeia, and technical terms.

\uFF00-\uFFEF: This range represents Full-width Latin characters, Full-width punctuation, and Full-width digits. In East Asia
n typography, full-width characters are wider than half-width characters and are commonly used in conjunction with CJK characters.

\u4E00-\u9FAF: This range represents CJK Unified Ideographs, which include common and uncommon Kanji characters used in Chine
se, Japanese, and Korean writing systems.

\u2605-\u2606: This range represents special star characters commonly used in East Asian languages.

\u2190-\u2195: This range represents arrow symbols, which are used in various contexts in East Asian typography.

\u203B: This range represents a specific reference mark character commonly used in Japanese typography to indicate footnotes
or as a separator in lists.
