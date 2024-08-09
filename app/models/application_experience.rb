class ApplicationExperience < ApplicationRecord
  belongs_to :application_form, touch: true
  belongs_to :experienceable, polymorphic: true, optional: true

  after_save -> { update_experienceable }, if: -> { experienceable.nil? }

  validates :role, :organisation, :start_date, presence: true

private

  def update_experienceable
    without_auditing do
      update!(experienceable: application_form)
    end
  end
end
