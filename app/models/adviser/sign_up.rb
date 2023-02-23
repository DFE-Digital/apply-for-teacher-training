class Adviser::SignUp
  class AdviserSignUpUnavailableError < RuntimeError; end

  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :application_form
  attribute :preferred_teaching_subject

  validates :preferred_teaching_subject, inclusion: { in: :teaching_subject_names, allow_blank: false }

  def initialize(application_form, *args, **kwargs)
    @application_form = Adviser::ApplicationFormValidations.new(application_form)

    super(*args, **kwargs)
  end

  def save
    raise AdviserSignUpUnavailableError unless available?

    return false if invalid?

    AdviserSignUpWorker.perform_async(application_form.id, preferred_teaching_subject_id)

    true
  end

  def available?
    feature_active? && application_form.valid?
  end

  def teaching_subjects
    @teaching_subjects ||= GetIntoTeachingApiClient::LookupItemsApi.new.get_teaching_subjects
  end

private

  def preferred_teaching_subject_id
    teaching_subjects.find { |subject| subject.value == preferred_teaching_subject }&.id
  end

  def teaching_subject_names
    teaching_subjects.map(&:value)
  end

  def feature_active?
    FeatureFlag.active?(:adviser_sign_up)
  end
end
