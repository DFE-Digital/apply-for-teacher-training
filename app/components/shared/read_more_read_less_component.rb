class ReadMoreReadLessComponent < ApplicationComponent
  DEFAULT_OPTIONS = {
    preview_word_count: 100,
    show_more_text: 'Read more',
    show_less_text: 'Read less',
  }.freeze

  attr_reader :full_text, :options

  def initialize(full_text, options = {})
    @full_text = sanitize(full_text)
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def render?
    full_text.present?
  end

  def show_full_text?
    remaining_text.blank?
  end

  def short_text
    split_text[0]
  end

  def remaining_text
    split_text[1]
  end

private

  def preview_word_count
    options[:preview_word_count]
  end

  def split_text
    @split_text ||= [
      full_text.split[0..(preview_word_count - 1)].join(' '),
      full_text.split[preview_word_count..]&.join(' '),
    ]
  end
end
