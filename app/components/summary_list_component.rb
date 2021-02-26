class SummaryListComponent < ViewComponent::Base
  include ViewHelper
  validates :rows, presence: true

  def initialize(rows:)
    rows = transform_hash(rows) if rows.is_a?(Hash)
    @rows = rows
  end

  def any_row_has_action_span?
    @rows.select { |row| row.key?(:action) }.any?
  end

private

  attr_reader :rows

  def transform_hash(row_hash)
    row_hash.map do |key, value|
      {
        key: key,
        value: value,
      }
    end
  end
end
