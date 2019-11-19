class SummaryCardComponent < ActionView::Component::Base
  validates :rows, presence: true

  def initialize(rows:, border: true, editable: true)
    @rows = determine_rows(rows, editable)
    @border = border
  end

  def border_css_class
    @border ? '' : 'no-border'
  end

private

  attr_reader :rows

  def determine_rows(rows, editable)
    rows.map do |row|
      row.tap do |r|
        unless editable
          r.delete(:change_path)
          r.delete(:action_path)
        end
      end
    end
  end
end
