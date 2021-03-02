class FlatReasonsForRejectionExtractCopy
  include ActiveModel::Model

  attr_accessor :structured_rejection_reasons_hash, :candidate_behaviour, :didnt_reply_to_interview_offer, :didnt_attend_interview
  attr_accessor :candidate_behaviour_other_details, :candidate_behaviour_what_to_improve_details, :quality_of_application, :personal_statement
  attr_accessor :quality_of_application_personal_statement_what_to_improve, :subject_knowledge, :quality_of_application_subject_knowledge_what_to_improve_details
  attr_accessor :quality_of_application_other_what_to_improve_details, :quality_of_application_other_details, :qualifications, :no_maths_gcse
  attr_accessor :no_english_gcse, :no_science_gcse, :no_degree, :qualifications_other_details, :performance_at_interview
  attr_accessor :performance_at_interview_what_to_improve_details, :course_full, :offered_on_another_course, :honesty_and_professionalism
  attr_accessor :information_false_or_inaccurate, :honesty_and_professionalism_concerns_information_false_or_inaccurate_details
  attr_accessor :plagiarism, :honesty_and_professionalism_concerns_plagiarism_details, :references, :honesty_and_professionalism_concerns_references_details
  attr_accessor :honesty_and_professionalism_concerns_other_details, :safeguarding, :candidate_disclosed_information
  attr_accessor :safeguarding_concerns_candidate_disclosed_information_details, :vetting_disclosed_information, :safeguarding_concerns_vetting_disclosed_information_details
  attr_accessor :safeguarding_concerns_other_details, :other_advice_or_feedback, :interested_in_future_applications, :why_are_you_rejecting_this_application_details

  def self.build_hash(structured_rejection_reasons)
    @structured_rejection_reasons = structured_rejection_reasons
    new(
      candidate_behaviour: structured_rejection_reasons.top_level_present?('candidate_behaviour_y_n'),
      didnt_reply_to_interview_offer: structured_rejection_reasons.sub_level_present?('candidate_behaviour_what_did_the_candidate_do', 'didnt_reply_to_interview_offer'),
      didnt_attend_interview: structured_rejection_reasons.sub_level_present?('candidate_behaviour_what_did_the_candidate_do', 'didnt_attend_interview'),
      candidate_behaviour_other_details: structured_rejection_reasons.sub_level_details_present?('candidate_behaviour_other'),
      candidate_behaviour_what_to_improve_details: structured_rejection_reasons.sub_level_details_present?('candidate_behaviour_what_to_improve'),
      quality_of_application: structured_rejection_reasons.top_level_present?('quality_of_application_y_n'),
      personal_statement: structured_rejection_reasons.sub_level_present?('quality_of_application_which_parts_needed_improvement', 'personal_statement'),
      quality_of_application_personal_statement_what_to_improve: structured_rejection_reasons.sub_level_details_present?('quality_of_application_personal_statement_what_to_improve'),
      subject_knowledge: structured_rejection_reasons.sub_level_present?('quality_of_application_which_parts_needed_improvement', 'subject_knowledge'),
      quality_of_application_subject_knowledge_what_to_improve_details: structured_rejection_reasons.sub_level_details_present?('quality_of_application_subject_knowledge_what_to_improve'),
      quality_of_application_other_what_to_improve_details: structured_rejection_reasons.sub_level_details_present?('quality_of_application_other_what_to_improve'),
      quality_of_application_other_details: structured_rejection_reasons.sub_level_details_present?('quality_of_application_other_details'),
      qualifications: structured_rejection_reasons.top_level_present?('qualifications_y_n'),
      no_maths_gcse: structured_rejection_reasons.sub_level_present?('qualifications_which_qualifications', 'no_maths_gcse'),
      no_english_gcse: structured_rejection_reasons.sub_level_present?('qualifications_which_qualifications', 'no_english_gcse'),
      no_science_gcse: structured_rejection_reasons.sub_level_present?('qualifications_which_qualifications', 'no_science_gcse'),
      no_degree: structured_rejection_reasons.sub_level_present?('qualifications_which_qualifications', 'no_degree'),
      qualifications_other_details: structured_rejection_reasons.sub_level_details_present?('qualifications_other_details'),
      performance_at_interview: structured_rejection_reasons.top_level_present?('performance_at_interview_y_n'),
      performance_at_interview_what_to_improve_details: structured_rejection_reasons.sub_level_details_present?('performance_at_interview_what_to_improve'),
      course_full: structured_rejection_reasons.top_level_present?('course_full_y_n'),
      offered_on_another_course: structured_rejection_reasons.top_level_present?('offered_on_another_course_y_n'),
      honesty_and_professionalism: structured_rejection_reasons.top_level_present?('honesty_and_professionalism_y_n'),
      information_false_or_inaccurate: structured_rejection_reasons.sub_level_present?('honesty_and_professionalism_concerns', 'information_false_or_inaccurate'),
      honesty_and_professionalism_concerns_information_false_or_inaccurate_details: structured_rejection_reasons.sub_level_details_present?('honesty_and_professionalism_concerns_information_false_or_inaccurate_details'),
      plagiarism: structured_rejection_reasons.sub_level_present?('honesty_and_professionalism_concerns', 'plagiarism'),
      honesty_and_professionalism_concerns_plagiarism_details: structured_rejection_reasons.sub_level_details_present?('honesty_and_professionalism_concerns_plagiarism_details'),
      references: structured_rejection_reasons.sub_level_present?('honesty_and_professionalism_concerns', 'references'),
      honesty_and_professionalism_concerns_references_details: structured_rejection_reasons.sub_level_details_present?('honesty_and_professionalism_concerns_references_details'),
      honesty_and_professionalism_concerns_other_details: structured_rejection_reasons.sub_level_details_present?('honesty_and_professionalism_concerns_other_details'),
      safeguarding: structured_rejection_reasons.top_level_present?('safeguarding_y_n'),
      candidate_disclosed_information: structured_rejection_reasons.sub_level_present?('safeguarding_concerns', 'candidate_disclosed_information'),
      safeguarding_concerns_candidate_disclosed_information_details: structured_rejection_reasons.sub_level_details_present?('safeguarding_concerns_candidate_disclosed_information_details'),
      vetting_disclosed_information: structured_rejection_reasons.sub_level_present?('safeguarding_concerns', 'vetting_disclosed_information'),
      safeguarding_concerns_vetting_disclosed_information_details: structured_rejection_reasons.sub_level_details_present?('safeguarding_concerns_vetting_disclosed_information_details'),
      safeguarding_concerns_other_details: structured_rejection_reasons.sub_level_details_present?('safeguarding_concerns_other_details'),
      other_advice_or_feedback: structured_rejection_reasons.top_level_present?('other_advice_or_feedback_y_n'),
      interested_in_future_applications: structured_rejection_reasons.top_level_present?('interested_in_future_applications_y_n'),
      why_are_you_rejecting_this_application_details: structured_rejection_reasons.sub_level_details_present?('why_are_you_rejecting_this_application')
    )
  end

  # These three methods are copied from the application_choices_export.rb & equality_and_diversity_export.rb - will be refactored later
  def formatted
    return nil if @structured_rejection_reasons.blank?

    select_top_level_rejection_reasons(@structured_rejection_reasons)
    .keys
    .map { |reason| format_reason(reason) }
    .join("\n")
  end

  def select_top_level_rejection_reasons(structured_rejection_reasons)
    structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason.include?('_y_n') }
  end

  def format_reason(reason)
    reason
    .delete_suffix('_y_n')
    .humanize
  end

private

  def sub_level_present?(key, value)
    return false if structured_rejection_reasons[key.to_s].blank?

    structured_rejection_reasons[key.to_s].include?(value.to_s)
  end

  def top_level_present?(key)
    return false if structured_rejection_reasons[key.to_s].blank?

    structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason == key.to_s }.present?
  end

  def sub_level_details_present?(key)
    return false if structured_rejection_reasons[key.to_s].blank?

    structured_rejection_reasons[key.to_s]
  end
end
