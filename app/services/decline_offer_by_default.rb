class DeclineOfferByDefault
  attr_accessor :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_choices = []

    ActiveRecord::Base.transaction do
      application_form.application_choices.offer.each do |application_choice|
        application_choice.update!(declined_by_default: true, declined_at: Time.zone.now)
        ApplicationStateChange.new(application_choice).decline_by_default!
        application_choices << application_choice
      end
    end

    application_choices.each do |application_choice|
      application_choice.provider.provider_users.each do |provider_user|
        ProviderMailer.declined_by_default(provider_user, application_choice).deliver_later
      end
    end

    if application_form.ended_without_success? && FeatureFlag.active?('apply_again') && rejected_course_choice_count.zero?
      CandidateMailer.declined_by_default_without_rejections(application_form).deliver_later
    elsif application_form.ended_without_success? && FeatureFlag.active?('apply_again')
      CandidateMailer.declined_by_default_with_rejections(application_form).deliver_later
    else
      CandidateMailer.declined_by_default(application_form).deliver_later
    end
  end

private

  def rejected_course_choice_count
    @application_form.application_choices.select(&:rejected?).count
  end
end
