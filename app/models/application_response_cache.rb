class ApplicationResponseCache < ApplicationRecord
  belongs_to :application_choice

  attr_accessor :response_body
end
