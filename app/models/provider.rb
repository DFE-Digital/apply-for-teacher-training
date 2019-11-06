class Provider < ApplicationRecord
  has_many :courses
  has_many :sites
  has_many :course_options, through: :courses
  has_many :application_choices, through: :course_options

  def visible_applications
    # TODO: include `.where('status != ?', 'unsubmitted')` here
    application_choices
  end
end
