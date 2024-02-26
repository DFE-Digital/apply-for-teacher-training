class ValidForNotifyValidator < ActiveModel::EachValidator
  NUMBERS_AND_LETTERS = 'a-zA-Z0-9'.freeze
  CHINESE_JAPANESE_AND_KOREAN_CHARS = '\u3000-\u303F\u3040-\u309F\u30A0-\u30FF\uFF00-\uFFEF\u4E00-\u9FAF\u2605-\u2606\u2190-\u2195\u203B'.freeze
  ALPHANUMERIC = "#{NUMBERS_AND_LETTERS}#{CHINESE_JAPANESE_AND_KOREAN_CHARS}".freeze
  EMAIL_REGEX = %r{\A[#{ALPHANUMERIC}.!\#$%&'*+/=?^_`{|}~-] # Local part
                  +@[#{ALPHANUMERIC}](?:[#{ALPHANUMERIC}-] # Domain name
                  {0,61}[#{ALPHANUMERIC}])?(?:\. # Allow periods in domain name
                  [#{ALPHANUMERIC}](?:[#{ALPHANUMERIC}-]{0,61}[#{ALPHANUMERIC}])?)*\.
                  [#{ALPHANUMERIC}](?:[#{ALPHANUMERIC}-]{0,61} # # End of domain
                  [#{ALPHANUMERIC}])\z}x

  # (?: ... ): Non-capturing group for invalid patterns.
  # [^.@]+\.@: Matches when the local part ends with a dot followed by @.
  # |: Or.
  # [^.@]+\.\.: Matches when there are consecutive dots in the local part.
  # |: Or.
  # [^.@]+@[^\s.]+\.\z: Matches when there's no domain name after the @ symbol.
  # |: Or.
  # \d+\z: Matches one or more digits followed by the end of the string
  #
  INVALID_EMAIL_REGEX_EDGE_CASES = /\A(?:[^.@]+\.@|[^.@]+\.\.|[^.@]+@[^\s.]+\.\z)|\d+\z/

  def validate_each(record, attribute, value)
    if value.blank? || !value.match?(EMAIL_REGEX) || value.match?(INVALID_EMAIL_REGEX_EDGE_CASES)
      record.errors.add(attribute, I18n.t('validation_errors.email_address_format'))
    end
  end
end
