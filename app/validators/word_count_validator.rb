class WordCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # This RegExp should match the implementation in govuk-frontend:
    # https://github.com/alphagov/govuk-frontend/blob/aa30ee76a5f84e230a323bb92d341285a6da3a10/src/govuk/components/character-count/character-count.js#L82

    word_count = value.scan(/\S+/).size

    if word_count > options[:maximum]
      record.errors.add(attribute, :too_many_words, maximum: options[:maximum], count: (word_count - options[:maximum]))
    end
  end
end
