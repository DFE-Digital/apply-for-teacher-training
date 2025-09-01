class ProviderInterface::ConfirmDeferredOfferForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :course_id
  attribute :location_id
  attribute :study_mode
  attribute :conditions_status

  attribute :conditions, readonly: true
  attribute :application_choice, readonly: true
  attribute :offer_conditions_status, readonly: true

  def course
    Course.find_by(id: course_id)
  end

  def location
    Site.find_by(id: location_id)
  end
end
