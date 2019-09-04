class Course < ApplicationRecord
  belongs_to :provider
  belongs_to :accredited_body, class_name: "Provider", foreign_key: :accredited_body_provider_id
end
