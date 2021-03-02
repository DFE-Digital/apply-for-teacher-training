class FlatReasonsForRejectionExtract
  include ActiveModel::Model

  attr_accessor :structured_rejection_reasons_hash

  def initialize(structured_rejection_reasons)
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def build_hash
    @structured_rejection_reasons_hash = @structured_rejection_reasons.merge(mapped_rejection_reasons)
    @structured_rejection_reasons_hash.each do |key, value|
      self.class.send :define_method, key do value end
    end
  end

  def mapped_rejection_reasons
    { 'candidate_behaviour?' => top_level_present?('candidate_behaviour_y_n'),
      'didnt_reply_to_interview_offer?' => sub_level_present?('candidate_behaviour_what_did_the_candidate_do', 'didnt_reply_to_interview_offer'),
      'didnt_attend_interview?' => sub_level_present?('candidate_behaviour_what_did_the_candidate_do', 'didnt_attend_interview'),
      'candidate_behaviour_other_details' => sub_level_details_present?('candidate_behaviour_other'),
      'candidate_behaviour_what_to_improve_details' => sub_level_details_present?('candidate_behaviour_what_to_improve'),
      'quality_of_application?' => top_level_present?('quality_of_application_y_n'),
      'personal_statement?' => sub_level_present?('quality_of_application_which_parts_needed_improvement', 'personal_statement'),
      'quality_of_application_personal_statement_what_to_improve' => sub_level_details_present?('quality_of_application_personal_statement_what_to_improve'),
      'subject_knowledge?' => sub_level_present?('quality_of_application_which_parts_needed_improvement', 'subject_knowledge'),
      'quality_of_application_subject_knowledge_what_to_improve_details' => sub_level_details_present?('quality_of_application_subject_knowledge_what_to_improve'),
      'quality_of_application_other_what_to_improve_details' => sub_level_details_present?('quality_of_application_other_what_to_improve'),
      'quality_of_application_other_details' => sub_level_details_present?('quality_of_application_other_details'),
      'qualifications?' => top_level_present?('qualifications_y_n'),
      'no_maths_gcse?' => sub_level_present?('qualifications_which_qualifications', 'no_maths_gcse'),
      'no_english_gcse?' => sub_level_present?('qualifications_which_qualifications', 'no_english_gcse'),
      'no_science_gcse?' => sub_level_present?('qualifications_which_qualifications', 'no_science_gcse'),
      'no_degree?' => sub_level_present?('qualifications_which_qualifications', 'no_degree'),
      'qualifications_other_details' => sub_level_details_present?('qualifications_other_details'),
      'performance_at_interview?' => top_level_present?('performance_at_interview_y_n'),
      'performance_at_interview_what_to_improve_details' => sub_level_details_present?('performance_at_interview_what_to_improve'),
      'course_full?' => top_level_present?('course_full_y_n'),
      'offered_on_another_course?' => top_level_present?('offered_on_another_course_y_n'),
      'honesty_and_professionalism?' => top_level_present?('honesty_and_professionalism_y_n'),
      'information_false_or_inaccurate?' => sub_level_present?('honesty_and_professionalism_concerns', 'information_false_or_inaccurate'),
      'honesty_and_professionalism_concerns_information_false_or_inaccurate_details' => sub_level_details_present?('honesty_and_professionalism_concerns_information_false_or_inaccurate_details'),
      'plagiarism?' => sub_level_present?('honesty_and_professionalism_concerns', 'plagiarism'),
      'honesty_and_professionalism_concerns_plagiarism_details' => sub_level_details_present?('honesty_and_professionalism_concerns_plagiarism_details'),
      'references?' => sub_level_present?('honesty_and_professionalism_concerns', 'references'),
      'honesty_and_professionalism_concerns_references_details' => sub_level_details_present?('honesty_and_professionalism_concerns_references_details'),
      'honesty_and_professionalism_concerns_other_details' => sub_level_details_present?('honesty_and_professionalism_concerns_other_details'),
      'safeguarding?' => top_level_present?('safeguarding_y_n'),
      'candidate_disclosed_information?' => sub_level_present?('safeguarding_concerns', 'candidate_disclosed_information'),
      'safeguarding_concerns_candidate_disclosed_information_details' => sub_level_details_present?('safeguarding_concerns_candidate_disclosed_information_details'),
      'vetting_disclosed_information?' => sub_level_present?('safeguarding_concerns', 'vetting_disclosed_information'),
      'safeguarding_concerns_vetting_disclosed_information_details' => sub_level_details_present?('safeguarding_concerns_vetting_disclosed_information_details'),
      'safeguarding_concerns_other_details' => sub_level_details_present?('safeguarding_concerns_other_details'),
      'other_advice_or_feedback?' => top_level_present?('other_advice_or_feedback_y_n'),
      'interested_in_future_applications?' => top_level_present?('interested_in_future_applications_y_n'),
      'why_are_you_rejecting_this_application_details' => sub_level_details_present?('why_are_you_rejecting_this_application') }
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
    return false if @structured_rejection_reasons[key.to_s].blank?

    @structured_rejection_reasons[key.to_s].include?(value.to_s)
  end

  def top_level_present?(key)
    return false if @structured_rejection_reasons[key.to_s].blank?

    @structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason == key.to_s }.present?
  end

  def sub_level_details_present?(key)
    return false if @structured_rejection_reasons[key.to_s].blank?

    @structured_rejection_reasons[key.to_s]
  end
end
