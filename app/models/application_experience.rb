class ApplicationExperience < ApplicationRecord
  self.ignored_columns += %w[application_form_id]
  belongs_to :experienceable, polymorphic: true, touch: true

  after_commit do
    if application_form
      experienceable.touch_choices
    end
  end

  validates :role, :organisation, :start_date, presence: true

  audited associated_with: :experienceable

  def application_form
    experienceable if experienceable_type == 'ApplicationForm'
  end
end
