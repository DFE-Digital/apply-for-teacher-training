class Course < ApplicationRecord
  belongs_to :provider
  belongs_to :accredited_body, class_name: 'Provider', foreign_key: :accredited_body_provider_id

  has_many :course_choices
  has_many :training_locations, through: :course_choices

  def provider_or_accredited_body?(provider_code)
    provider_code.in?([provider.code, accredited_body.code])
  end
end
