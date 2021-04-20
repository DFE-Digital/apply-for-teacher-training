class OfferValidations
  include ActiveModel::Model

  attr_accessor :course_option

  validates :course_option, presence: true
end
