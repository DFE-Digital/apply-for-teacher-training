class FlatReasonsForRejectionExtract
  include ActiveModel::Model

  def initialize(structured_rejection_reasons)
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def candidate_behaviour?
    top_level_reasons('candidate_behaviour_y_n')
  end

  def didnt_reply_to_interview_offer?
    sub_level_reasons('candidate_behaviour_what_did_the_candidate_do', 'didnt_reply_to_interview_offer')
  end

  def didnt_attend_interview?
    sub_level_reasons('candidate_behaviour_what_did_the_candidate_do', 'didnt_attend_interview')
  end

  def candidate_behaviour_other_details
    other_detail_or_what_to_improve('candidate_behaviour_other')
  end

  def quality_of_application?
    top_level_reasons('quality_of_application_y_n')
  end

  def personal_statement?
    sub_level_reasons('quality_of_application_which_parts_needed_improvement', 'personal_statement')
  end

  def quality_of_application_personal_statement_what_to_improve
    other_detail_or_what_to_improve('quality_of_application_personal_statement_what_to_improve')
  end

  def subject_knowledge?
    sub_level_reasons('quality_of_application_which_parts_needed_improvement', 'subject_knowledge')
  end

  def quality_of_application_subject_knowledge_what_to_improve
    other_detail_or_what_to_improve('quality_of_application_subject_knowledge_what_to_improve')
  end

  def quality_of_application_other_details
    other_detail_or_what_to_improve('quality_of_application_other_details')
  end

  def qualifications?
    top_level_reasons('qualifications_y_n')
  end

  def no_maths_gcse?
    sub_level_reasons('qualifications_which_qualifications', 'no_maths_gcse')
  end

  def no_science_gcse?
    sub_level_reasons('qualifications_which_qualifications', 'no_science_gcse')
  end

  def no_english_gcse?
    sub_level_reasons('qualifications_which_qualifications', 'no_english_gcse')
  end

  def no_degree?
    sub_level_reasons('qualifications_which_qualifications', 'no_degree')
  end

  def qualifications_other_details
    other_detail_or_what_to_improve('qualifications_other_details')
  end

  def performance_at_interview?
    top_level_reasons('performance_at_interview_y_n')
  end

  def performance_at_interview_what_to_improve
    other_detail_or_what_to_improve('performance_at_interview_what_to_improve')
  end

  def course_full?
    top_level_reasons('course_full_y_n')
  end

  def offered_on_another_course?
    top_level_reasons('offered_on_another_course_y_n')
  end

  def honesty_and_professionalism?
    top_level_reasons('honesty_and_professionalism_y_n')
  end

  def information_false_or_inaccurate?
    sub_level_reasons('honesty_and_professionalism_concerns', 'information_false_or_inaccurate')
  end

  def plagiarism?
    sub_level_reasons('honesty_and_professionalism_concerns', 'plagiarism')
  end

  def references?
    sub_level_reasons('honesty_and_professionalism_concerns', 'references')
  end

  def honesty_and_professionalism_concerns_information_false_or_inaccurate_details
    other_detail_or_what_to_improve('honesty_and_professionalism_concerns_information_false_or_inaccurate_details')
  end

  def honesty_and_professionalism_concerns_plagiarism_details
    other_detail_or_what_to_improve('honesty_and_professionalism_concerns_plagiarism_details')
  end

  def honesty_and_professionalism_concerns_references_details
    other_detail_or_what_to_improve('honesty_and_professionalism_concerns_references_details')
  end

  def honesty_and_professionalism_concerns_other_details
    other_detail_or_what_to_improve('honesty_and_professionalism_concerns_other_details')
  end

  def safeguarding?
    top_level_reasons('safeguarding_y_n')
  end

  def candidate_disclosed_information?
    sub_level_reasons('safeguarding_concerns', 'candidate_disclosed_information')
  end

  def safeguarding_concerns_candidate_disclosed_information_details
    other_detail_or_what_to_improve('safeguarding_concerns_candidate_disclosed_information_details')
  end

  def vetting_disclosed_information?
    sub_level_reasons('safeguarding_concerns', 'vetting_disclosed_information')
  end

  def safeguarding_concerns_vetting_disclosed_information_details
    other_detail_or_what_to_improve('safeguarding_concerns_vetting_disclosed_information_details')
  end

  def safeguarding_concerns_other_details
    other_detail_or_what_to_improve('safeguarding_concerns_other_details')
  end

  # These three methods are copied from the application_choices_export.rb .... currently doesn't provide enough granularity
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

  def top_level_reasons(key)
    return nil if @structured_rejection_reasons[key.to_s].blank?

    @structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason == key.to_s }.present?
  end

  def sub_level_reasons(key, value)
    return nil if @structured_rejection_reasons[key.to_s].blank?

    @structured_rejection_reasons[key.to_s].include?(value.to_s)
  end

  def other_detail_or_what_to_improve(key)
    return nil if @structured_rejection_reasons[key.to_s].blank?

    @structured_rejection_reasons[key.to_s]
  end
end
