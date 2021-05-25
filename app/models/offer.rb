class Offer < ApplicationRecord
  belongs_to :application_choice
  has_many :conditions, class_name: 'OfferCondition'
end
