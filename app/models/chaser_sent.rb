class ChaserSent < ApplicationRecord
  belongs_to :chased, polymorphic: true

  scope :since_service_opened, lambda { |service|
    where('created_at >= ?', RecruitmentCycleTimetable.current_timetable.send("#{service}_opens_at"))
  }
  scope :since_application_deadline, -> { where('created_at > ?', RecruitmentCycleTimetable.current_timetable.apply_deadline_at) }

  enum :chaser_type, {
    ######################################
    ####     Service availability     ####
    ######################################

    ## ProviderMailer ##
    apply_service_is_now_open: 'apply_service_is_now_open',
    find_service_is_now_open: 'find_service_is_now_open',
    find_service_open_organisation_notification: 'find_service_open_organisation_notification',
    respond_to_applications_before_reject_by_default_date: 'respond_to_applications_before_reject_by_default_date',

    ## CandidateMailer ##
    eoc_first_deadline_reminder: 'eoc_first_deadline_reminder',
    eoc_second_deadline_reminder: 'eoc_second_deadline_reminder',
    find_has_opened: 'find_has_opened',
    new_cycle_has_started: 'new_cycle_has_started',

    #### DEPRECATED ####
    apply_service_open_organisation_notification: 'apply_service_open_organisation_notification',
    eoc_deadline_reminder: 'eoc_deadline_reminder',

    ######################################
    ####          References          ####
    ######################################

    #### RefereeMailer ####
    referee_follow_up_missing_references: 'referee_follow_up_missing_references',
    referee_reference_request: 'referee_reference_request',
    reminder_reference_nudge: 'reminder_reference_nudge',

    ### CandidateMailer ####
    candidate_follow_up_missing_references: 'candidate_follow_up_missing_references',
    candidate_reference_request: 'candidate_reference_request',
    reference_replacement: 'reference_replacement',

    #### DEPRECATED ####
    reference_request: 'reference_request',
    follow_up_missing_references: 'follow_up_missing_references',

    ######################################
    ####           Inactive           ####
    ######################################

    #### CandidateMailer ####
    apply_to_another_course_after_30_working_days: 'apply_to_another_course_after_30_working_days',
    apply_to_multiple_courses_after_30_working_days: 'apply_to_multiple_courses_after_30_working_days',

    ######################################
    ####            Offer             ####
    ######################################

    #### CandidateMailer ####
    candidate_decision_request: 'candidate_decision_request',
    offer_10_day: 'offer_10_day',
    offer_20_day: 'offer_20_day',
    offer_30_day: 'offer_30_day',
    offer_40_day: 'offer_40_day',
    offer_50_day: 'offer_50_day',

    ######################################
    ####      Course unavailable      ####
    ######################################

    #### CandidateMailer ####
    course_unavailable_notification: 'course_unavailable_notification',
    course_unavailable_slack_notification: 'course_unavailable_slack_notification',

    ######################################
    ####         Permissions          ####
    ######################################

    #### ProviderMailer ####
    set_up_organisation_permissions: 'set_up_organisation_permissions',
  }
end
