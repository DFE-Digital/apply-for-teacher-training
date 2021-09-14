class CandidateInterface::PendingGcseRequiredComponent < ViewComponent::Base
  attr_accessor :application_choice, :pending_uk_gcses

  def initialize(application_choice)
    @application_choice = application_choice
    @pending_uk_gcses = find_pending_uk_gcses(application_choice)
  end

  def pending_gcse_and_course_can_accept?
    @pending_uk_gcses.any? && !@application_choice.course.accept_pending_gcse?
  end

private

  def pending_gcse_text
    subjects = pending_uk_gcses.map(&:subject)
    subjects[0] = subjects[0].capitalize
    subjects.to_sentence(last_word_connector: ' and ', two_words_connector: ' and ')
  end

  def find_pending_uk_gcses(application_choice)
    application_choice.application_form.application_qualifications
      .where(level: 'gcse', other_uk_qualification_type: nil, institution_country: [nil, 'GB'], currently_completing_qualification: true)
  end
end
