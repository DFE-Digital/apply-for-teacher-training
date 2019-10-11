class WordCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # This RegExp should match the implementation in govuk-frontend:
    # https://github.com/alphagov/govuk-frontend/blob/aa30ee76a5f84e230a323bb92d341285a6da3a10/src/govuk/components/character-count/character-count.js#L82
    if value.scan(/\S+/).size > options[:maximum]
      record.errors[attribute] << (options[:message] || "Reduce the word count for #{attribute.to_s.humanize(capitalize: false)}")
    end
  end
end
