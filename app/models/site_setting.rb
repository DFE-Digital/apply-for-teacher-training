class SiteSetting < ApplicationRecord
  audited

  validates :name, uniqueness: true

  def self.cycle_schedule
    find_or_create_by!(name: 'cycle_schedule').value&.to_sym || :real
  end

  def self.set(name:, value:)
    find_or_create_by!(name: name).update!(value: value)
  end
end
