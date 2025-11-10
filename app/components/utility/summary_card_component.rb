class SummaryCardComponent < ViewComponent::Base
  def initialize(rows:, border: true, editable: true, ignore_editable: [], warning_text: nil)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows_including_actions_if_editable(rows, editable, ignore_editable)
    @border = border
    @warning_text = warning_text
  end

  def border_css_class
    @border ? '' : 'no-border'
  end

private

  attr_reader :rows, :ignore_editable, :warning_text

  def rows_including_actions_if_editable(rows, editable, ignore_editable)
    rows.map do |row|
      row.tap do |r|
        next if r[:key].in? ignore_editable

        unless editable
          r.delete(:action)
        end
      end
    end
  end

  def transform_hash(row_hash)
    row_hash.map do |key, value|
      {
        key:,
        value:,
      }
    end
  end
end
