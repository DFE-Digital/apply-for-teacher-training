class Provider < ApplicationRecord
  has_many :courses
  has_many :application_choices, through: :courses

  def visible_applications
    # TODO: include `.where('status != ?', 'unsubmitted')` here
    application_choices
  end
end
