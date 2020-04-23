class SummaryCardComponent < ViewComponent::Base
  validates :rows, presence: true

  def initialize(rows:, border: true, editable: true)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows_including_actions_if_editable(rows, editable)
    @border = border
  end

  def border_css_class
    @border ? '' : 'no-border'
  end

private

  attr_reader :rows

  def rows_including_actions_if_editable(rows, editable)
    rows.map do |row|
      row.tap do |r|
        unless editable
          r.delete(:change_path)
          r.delete(:action_path)
          r.delete(:action)
        end
      end
    end
  end

  def transform_hash(row_hash)
    row_hash.map do |key, value|
      {
        key: key,
        value: value,
      }
    end
  end
end
