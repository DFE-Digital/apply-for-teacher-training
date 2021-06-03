class RejectedApplicationChoicePresenter < SimpleDelegator
  def rejection_reasons
    @rejection_reasons = single_reason_for_rejection if single_reason_for_rejection.present?

    @rejection_reasons ||= [candidate_behaviour, quality_of_application, qualifications,
                            interview_performance, full_course, offered_other_course,
                            honesty_and_professionalism_reasons, safeguarding_issues, cannot_sponsor_visa,
                            additional_advice, interested_in_future_applications].reduce({}, :merge)
  end

  def reasons
    @reasons ||= ReasonsForRejection.new(structured_rejection_reasons)
  end

private

  def single_reason_for_rejection
    return nil unless rejection_reason?

    { I18n.t('reasons_for_rejection.single_rejection_reason.title') => [rejection_reason] }
  end

  def candidate_behaviour
    return {} unless reasons.candidate_behaviour_y_n.eql?('Yes')

    candidate_behaviour = reasons.candidate_behaviour_what_did_the_candidate_do.inject([]) do |behaviour, reason|
      if reason == 'other'
        behaviour << reasons.candidate_behaviour_other
        behaviour << reasons.candidate_behaviour_what_to_improve
      else
        behaviour << I18n.t("reasons_for_rejection.candidate_behaviour_what_did_the_candidate_do.#{reason}")
      end
    end

    reason_details('candidate_behaviour', candidate_behaviour)
  end

  def quality_of_application
    return {} unless reasons.quality_of_application_y_n.eql?('Yes')

    application_quality = reasons.quality_of_application_which_parts_needed_improvement.inject([]) do |quality_reasons, reason|
      if reason == 'other'
        quality_reasons << reasons.quality_of_application_other_details
        quality_reasons << reasons.quality_of_application_other_what_to_improve
      else
        quality_reasons << reasons.send("quality_of_application_#{reason}_what_to_improve")
      end
    end

    reason_details('quality_of_application', application_quality)
  end

  def qualifications
    return {} unless reasons.qualifications_y_n.eql?('Yes')

    qualifications = reasons.qualifications_which_qualifications.inject([]) do |qualification_reasons, reason|
      if reason == 'other'
        qualification_reasons << reasons.qualifications_other_details
      else
        qualification_reasons << I18n.t("reasons_for_rejection.qualifications_which_qualifications.#{reason}")
      end
    end

    reason_details('qualifications', qualifications)
  end

  def interview_performance
    return {} unless reasons.performance_at_interview_y_n.eql?('Yes')

    reason_details('interview_performance', [reasons.performance_at_interview_what_to_improve])
  end

  def full_course
    return {} unless reasons.course_full_y_n.eql?('Yes')

    reason_details('full_course')
  end

  def offered_other_course
    return {} unless reasons.offered_on_another_course_y_n.eql?('Yes')

    reason_details('offered_on_another_course', [reasons.offered_on_another_course_details])
  end

  def honesty_and_professionalism_reasons
    return {} unless reasons.honesty_and_professionalism_y_n.eql?('Yes')

    honesty_and_professionalism = [reasons.honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                                   reasons.honesty_and_professionalism_concerns_plagiarism_details,
                                   reasons.honesty_and_professionalism_concerns_references_details,
                                   reasons.honesty_and_professionalism_concerns_other_details].compact

    reason_details('honesty_and_professionalism', honesty_and_professionalism)
  end

  def safeguarding_issues
    return {} unless reasons.safeguarding_y_n.eql?('Yes')

    safeguarding_issues = [reasons.safeguarding_concerns_candidate_disclosed_information_details,
                           reasons.safeguarding_concerns_vetting_disclosed_information_details,
                           reasons.safeguarding_concerns_other_details].compact

    reason_details('safeguarding_issues', safeguarding_issues)
  end

  def cannot_sponsor_visa
    return {} unless reasons.cannot_sponsor_visa_y_n.eql?('Yes')

    reason_details('cannot_sponsor_visa', [reasons.cannot_sponsor_visa_details])
  end

  def additional_advice
    return {} unless reasons.other_advice_or_feedback_y_n.eql?('Yes')

    reason_details('additional_advice', [reasons.other_advice_or_feedback_details])
  end

  def interested_in_future_applications
    return {} unless %w[Yes No].include?(reasons.interested_in_future_applications_y_n)

    reason_details(
      'interested_in_future_applications',
      [I18n.t("reasons_for_rejection.interested_in_future_applications.reason.#{reasons.interested_in_future_applications_y_n.downcase}",
              provider_name: course_option.course.provider.name)],
    )
  end

  def reason_details(key, reason = nil)
    reason ||= [I18n.t("reasons_for_rejection.#{key}.reason")]

    { I18n.t("reasons_for_rejection.#{key}.title") => reason }
  end
end
