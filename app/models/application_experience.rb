class ApplicationExperience < ApplicationRecord
  include AffectsApplicationAPIResponse

  validates :role, :organisation, :details, :start_date,
            presence: true

  validates :working_with_children, inclusion: { in: [true, false] }

  belongs_to :application_form
  has_many :application_choices, through: :application_form
end
