class SummaryListComponent < ViewComponent::Base
  validates :rows, presence: true

  def initialize(rows:)
    @rows = rows
  end

  def any_row_has_action_span?
    @rows.select { |row| row.has_key?(:action) }.any?
  end

private

  attr_reader :rows
end
