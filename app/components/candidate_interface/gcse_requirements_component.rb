class CandidateInterface::GcseRequirementsComponent < ApplicationComponent
  include ViewHelper

  attr_accessor :application_choice, :missing_uk_gcses, :pending_uk_gcses

  def initialize(application_choice)
    @application_choice = application_choice
    @missing_uk_gcses = find_missing_uk_gcses(application_choice)
    @pending_uk_gcses = find_pending_uk_gcses(application_choice)
  end

private

  def find_missing_uk_gcses(application_choice)
    application_choice.application_form.application_qualifications
      .where(level: 'gcse', qualification_type: 'missing', other_uk_qualification_type: nil, institution_country: [nil, 'GB'], currently_completing_qualification: false)
      .sort_by(&:subject)
  end

  def find_pending_uk_gcses(application_choice)
    application_choice.application_form.application_qualifications
      .where(level: 'gcse', other_uk_qualification_type: nil, institution_country: [nil, 'GB'], currently_completing_qualification: true)
      .sort_by(&:subject)
  end

  def candidate_has_missing_gcses?
    missing_uk_gcses.any?
  end

  def candidate_has_pending_gcses?
    pending_uk_gcses.any?
  end
end
