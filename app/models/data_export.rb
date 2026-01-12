class DataExport < ApplicationRecord
  EXPORT_TYPES = {
    active_provider_user_permissions: {
      name: 'Active provider user permissions',
      export_type: 'active_provider_user_permissions',
      description: 'The list of provider users with the permissions they have for each of their organisations.',
      class: SupportInterface::ActiveProviderUserPermissionsExport,
      deprecated: false,
    },
    active_provider_users: {
      name: 'Active users affiliated with a Provider',
      export_type: 'active_provider_users',
      description: 'The list of all users affiliated with a provider who have signed in to Manage at least once.',
      class: SupportInterface::ActiveProviderUsersExport,
      deprecated: false,
    },
    applications_by_subject_route_and_degree_grade: {
      name: 'Applications by subject, route and degree grade',
      export_type: 'applications_by_subject_route_and_degree_grade',
      description: 'Export of applications grouped by subject, route and degree grade',
      class: SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport,
      deprecated: true,
    },
    application_references: {
      name: 'Application references',
      export_type: 'application_references',
      description: 'A list of all application references which have been selected by candidates to date. All duplicate references caused by duplication of a candidates application form caused by Applying Again or carrying over their application between cycles have been removed.',
      class: SupportInterface::ApplicationReferencesExport,
      deprecated: true,
    },
    application_timings: {
      name: 'Application timings',
      export_type: 'application_timings',
      description: 'The application timings provides data for when an application form attribute was last updated by the candidate.',
      class: SupportInterface::ApplicationsExport,
      deprecated: true,
    },
    application_timings_for_current_cycle: {
      name: 'Application timings for current cycle',
      export_type: 'application_timings_for_current_cycle',
      description: 'The application timings provides data from the current cycle for when an application form attribute was last updated by the candidate.',
      class: SupportInterface::ApplicationsExport,
      export_options: { current_cycle: true },
      deprecated: true,
    },
    candidate_application_feedback: {
      name: 'Candidate application feedback',
      export_type: 'candidate_application_feedback',
      description: 'This provides the compiled results of all feedback received from prompts throughout the application form.',
      class: SupportInterface::CandidateApplicationFeedbackExport,
      deprecated: true,
    },
    candidate_autosuggest_usage: {
      name: 'Candidate autosuggest usage',
      export_type: 'candidate_autosuggest_usage',
      description: 'A summary of values stored in the database via autosuggest components within the candidate application form (Apply 1 only)',
      class: SupportInterface::CandidateAutofillUsageExport,
      deprecated: true,
    },
    candidate_email_send_counts: {
      name: 'Candidate email send counts',
      export_type: 'candidate_email_send_counts',
      description: "A list of all emails sent by the service, and how many we've sent to date.",
      class: SupportInterface::CandidateEmailSendCountsExport,
      deprecated: true,
    },
    candidate_feedback: {
      name: 'Candidate feedback',
      export_type: 'candidate_feedback',
      description: 'This provides the compiled results of all the single-page candidate feedback forms.',
      class: SupportInterface::CandidateFeedbackExport,
      deprecated: true,
    },
    candidate_journey_tracking: {
      name: 'Candidate journey tracking',
      export_type: 'candidate_journey_tracking',
      description: 'Candidate journey tracking provides data on when each application choice progressed through the various steps in the candidate application journey.',
      class: SupportInterface::CandidateJourneyTrackingExport,
      deprecated: true,
    },
    candidate_course_choice_withdrawal_survey: {
      name: 'Candidate course choice withdrawal survey',
      export_type: 'candidate_course_choice_withdrawal_survey',
      description: 'A list of candidates explanations for withdrawing a course choice. Also includes contact details for candidates who have agreed to be contacted.',
      class: SupportInterface::CourseChoiceWithdrawalSurveyExport,
      deprecated: true,
    },
    equality_and_diversity: {
      name: 'Equality and diversity data',
      export_type: 'equality_and_diversity',
      description: 'Anonymised candidate equality and diversity data.',
      class: SupportInterface::EqualityAndDiversityExport,
      deprecated: true,
    },
    find_feedback: {
      name: 'Find feedback',
      export_type: 'find_feedback',
      description: 'Feedback provided from the Find service results and course pages',
      class: SupportInterface::FindFeedbackExport,
      deprecated: true,
    },
    interviews_export: {
      name: 'Interview changes',
      export_type: 'interview_export',
      description: 'A list of changes made to interviews for analysis of the Interviews feature',
      class: SupportInterface::InterviewChangesExport,
      deprecated: true,
    },
    ministerial_report_applications_export: {
      name: 'Ministerial report - applications',
      export_type: 'ministerial_report_applications_export',
      description: 'A report of applications counted against specific states and subjects.',
      class: SupportInterface::MinisterialReportApplicationsExport,
      deprecated: false,
    },
    ministerial_report_candidates_export: {
      name: 'Ministerial report - candidates',
      export_type: 'ministerial_report_candidates_export',
      description: 'A report of candidates counted against specific states and subjects.',
      class: SupportInterface::MinisterialReportCandidatesExport,
      deprecated: false,
    },
    notes_export: {
      name: 'Notes',
      export_type: 'notes_export',
      description: 'Data related to notes made on applications by providers.',
      class: SupportInterface::NotesExport,
      deprecated: true,
    },
    notification_preferences_export: {
      name: 'Notification preferences changes',
      export_type: 'notification_preferences_export',
      description: 'Changes to notification preferences for provider users.',
      class: SupportInterface::NotificationPreferencesExport,
      deprecated: true,
    },
    notifications_export: {
      name: 'Notification preferences',
      export_type: 'notifications_export',
      description: 'Notification preferences for each provider user within each provider organisation.',
      class: SupportInterface::NotificationsExport,
      deprecated: true,
    },
    offer_conditions: {
      name: 'Offer conditions',
      export_type: 'offer_conditions',
      description: 'A list of all offers showing offer conditions alongside the qualifications declared by the candidate. One line per offer.',
      class: SupportInterface::OfferConditionsExport,
      deprecated: true,
    },
    organisation_permissions: {
      name: 'Organisation permissions changes',
      export_type: 'organisation_permissions',
      description: 'A list of changes to organisation permissions and audit information about the changes.',
      class: SupportInterface::OrganisationPermissionsExport,
      deprecated: true,
    },
    provider_access_controls: {
      name: 'Provider permissions stats',
      export_type: 'provider_access_controls',
      description: "A list of providers and aggregated information about the number of users they have, their permissions, the changes that they've made and their relationships to other organisations.",
      class: SupportInterface::ProviderAccessControlsExport,
      deprecated: true,
    },
    providers_export: {
      name: 'Providers',
      export_type: 'providers_export',
      description: 'The list of providers that are being synced from the Find service, along with when they signed the data sharing agreement.',
      class: SupportInterface::ProvidersExport,
      deprecated: true,
    },
    persona_export: {
      name: 'Persona data',
      export_type: 'persona_export',
      description: 'A list of application choices with the associated postcodes for the candidate, provider and site. Also includes reasons for rejection, nationality and application status.',
      class: SupportInterface::PersonaExport,
      deprecated: true,
    },
    qualifications: {
      name: 'Qualifications',
      export_type: 'qualifications',
      description: 'A list of qualifications for each application choice.',
      class: SupportInterface::QualificationsExport,
      deprecated: true,
    },
    referee_survey: {
      name: 'Referee survey',
      export_type: 'referee_survey',
      description: 'This provides the compiled results of all the referee surveys.',
      class: SupportInterface::RefereeSurveyExport,
      deprecated: true,
    },
    sites_export: {
      name: 'Sites',
      export_type: 'sites_export',
      description: 'A list of sites that are being synced from Find, along with distances to their respective providers.',
      class: SupportInterface::SitesExport,
      deprecated: true,
    },
    structured_reasons_for_rejection: {
      name: 'Structured reasons for rejection',
      export_type: 'structured_reasons_for_rejection',
      description: 'Structured reasons for rejection.',
      class: SupportInterface::StructuredReasonsForRejectionExport,
      deprecated: true,
    },
    submitted_application_choices: {
      name: 'Submitted application choices',
      export_type: 'submitted_application_choices',
      description: 'The submitted application choices export provides data about which courses candidates applied to, as well as info about offers and candidate decisions.',
      class: SupportInterface::ApplicationChoicesExport,
      deprecated: true,
    },
    submitted_application_choices_for_current_cycle: {
      name: 'Submitted application choices_for_current_cycle',
      export_type: 'submitted_application_choices',
      description: 'The submitted application choices export provides data about which courses candidates applied to, as well as info about offers and candidate decisions.',
      class: SupportInterface::ApplicationChoicesExport,
      export_options: { current_cycle: true },
      deprecated: true,
    },
    tad_applications: {
      name: 'TAD applications',
      export_type: 'tad_applications',
      description: 'A list of all applications for TAD.',
      class: DataAPI::TADExport,
      deprecated: false,
    },
    tad_provider_performance: {
      name: 'TAD provider performance',
      export_type: 'tad_provider_performance',
      description: 'A list of all application/offered/accepted counts for all courses in Apply belonging to the current recruitment cycle.',
      class: SupportInterface::TADProviderStatsExport,
      deprecated: false,
    },
    tad_subject_domicile_nationality: {
      name: 'TAD applications by subject, domicile and nationality',
      export_type: 'tad_subject_domicile_nationality',
      description: 'Report of subjects, candidate nationality, domicile and application status for TAD.',
      class: DataAPI::TADSubjectDomicileNationalityExport,
      deprecated: false,
    },
    applications_by_demographic_domicile_and_degree_class: {
      name: 'TAD applications by demographic, domicile and degree class',
      export_type: 'applications_by_demographic_domicile_and_degree_class',
      description: 'A list of all application/offered/accepted counts broken down by age group, sex, ethnicity and degree in Apply belonging to the current recruitment cycle.',
      class: SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport,
      deprecated: true,
    },
    user_permissions: {
      name: 'User permissions changes',
      export_type: 'user_permissions',
      description: 'A list of changes to user permissions and audit information about the changes.',
      class: SupportInterface::UserPermissionsExport,
      deprecated: true,
    },
    who_ran_which_export: {
      name: 'Who ran which export',
      export_type: 'who_ran_which_export',
      description: 'A list of all the exports that have been generated and who initiated them.',
      class: SupportInterface::WhoRanWhichExportExport,
      deprecated: false,
    },
    work_history_break: {
      name: 'Work history break',
      export_type: 'work_history_break',
      description: 'A list of candidates with breaks in their work history.',
      class: SupportInterface::WorkHistoryBreakExport,
      deprecated: true,
    },
  }.freeze

  belongs_to :initiator, polymorphic: true, optional: true

  has_one_attached :file

  audited except: [:data]

  def self.active_export_types
    EXPORT_TYPES.filter do |_export_type, values|
      !values[:deprecated]
    end
  end

  def self.deprecated_export_types
    EXPORT_TYPES.filter do |_export_type, values|
      values[:deprecated]
    end
  end

  def export_type_deprecated?
    EXPORT_TYPES.dig(
      export_type.to_sym,
      :deprecated,
    )
  end

  def filename
    "#{name.parameterize}-#{created_at}.csv"
  end

  def month_filename
    "#{name.parameterize}-#{created_at.strftime('%Y-%m')}.csv"
  end

  def generation_time
    (completed_at - created_at).seconds.ceil
  end

  def initiator_name
    initiator&.display_name || 'an automated process'
  end

  def export_type_value
    name.parameterize.underscore
  end

  enum :export_type, {
    active_provider_user_permissions: 'active_provider_user_permissions',
    active_provider_users: 'active_provider_users',
    applications_by_demographic_domicile_and_degree_class: 'applications_by_demographic_domicile_and_degree_class',
    applications_by_subject_route_and_degree_grade: 'applications_by_subject_route_and_degree_grade',
    application_references: 'application_references',
    application_timings: 'application_timings',
    application_timings_for_current_cycle: 'application_timings_for_current_cycle',
    candidate_application_feedback: 'candidate_application_feedback',
    candidate_autosuggest_usage: 'candidate_autosuggest_usage',
    candidate_email_send_counts: 'candidate_email_send_counts',
    candidate_feedback: 'candidate_feedback',
    candidate_journey_tracking: 'candidate_journey_tracking',
    candidate_course_choice_withdrawal_survey: 'candidate_course_choice_withdrawal_survey',
    equality_and_diversity: 'equality_and_diversity',
    external_report_applications: 'external_report_applications',
    external_report_candidates: 'external_report_candidates',
    find_feedback: 'find_feedback',
    interviews_export: 'interview_export',
    ministerial_report_applications_export: 'ministerial_report_applications_export',
    ministerial_report_candidates_export: 'ministerial_report_candidates_export',
    notifications_export: 'notifications_export',
    notification_preferences_export: 'notification_preferences_export',
    notes_export: 'notes_export',
    offer_conditions: 'offer_conditions',
    organisation_permissions: 'organisation_permissions',
    provider_access_controls: 'provider_access_controls',
    providers_export: 'providers_export',
    persona_export: 'persona_export',
    qualifications: 'qualifications',
    referee_survey: 'referee_survey',
    sites_export: 'sites_export',
    structured_reasons_for_rejection: 'structured_reasons_for_rejection',
    submitted_application_choices: 'submitted_application_choices',
    submitted_application_choices_for_current_cycle: 'submitted_application_choices_for_current_cycle',
    tad_applications: 'tad_applications',
    tad_provider_performance: 'tad_provider_performance',
    tad_subject_domicile_nationality: 'tad_subject_domicile_nationality',
    user_permissions: 'user_permissions',
    who_ran_which_export: 'who_ran_which_export',
    work_history_break: 'work_history_break',
  }
end
