class DataExport < ApplicationRecord
  EXPORT_TYPES = {
    active_provider_user_permissions: {
      name: 'Active provider user permissions',
      export_type: 'active_provider_user_permissions',
      description: 'The list of provider users with the permissions they have for each of their organisations.',
      class: SupportInterface::ActiveProviderUserPermissionsExport,
    },
    active_provider_users: {
      name: 'Active provider users',
      export_type: 'active_provider_users',
      description: 'The list of provider users that have signed in to apply at least once.',
      class: SupportInterface::ActiveProviderUsersExport,
    },
    application_references: {
      name: 'Application references',
      export_type: 'application_references',
      description: 'A list of all application references which have been selected by candidates to date. All duplicate references caused by duplication of a candidates application form caused by Applying Again or carrying over their application between cycles have been removed.',
      class: SupportInterface::ApplicationReferencesExport,
    },
    application_timings: {
      name: 'Application timings',
      export_type: 'application_timings',
      description: 'The application timings provides data on when an application form attribute was last updated by the candidate.',
      class: SupportInterface::ApplicationsExport,
    },
    candidate_application_feedback: {
      name: 'Candidate application feedback',
      export_type: 'candidate_application_feedback',
      description: 'This provides the compiled results of all feedback received from prompts throughout the application form.',
      class: SupportInterface::CandidateApplicationFeedbackExport,
    },
    candidate_autosuggest_usage: {
      name: 'Candidate autosuggest usage',
      export_type: 'candidate_autosuggest_usage',
      description: 'A summary of values stored in the database via autosuggest components within the candidate application form (Apply 1 only)',
      class: SupportInterface::CandidateAutofillUsageExport,
    },
    candidate_email_send_counts: {
      name: 'Candidate email send counts',
      export_type: 'candidate_email_send_counts',
      description: "A list of all emails sent by the service, and how many we've sent to date.",
      class: SupportInterface::CandidateEmailSendCountsExport,
    },
    candidate_feedback: {
      name: 'Candidate feedback',
      export_type: 'candidate_feedback',
      description: 'This provides the compiled results of all the single-page candidate feedback forms.',
      class: SupportInterface::CandidateFeedbackExport,
    },
    candidate_journey_tracking: {
      name: 'Candidate journey tracking',
      export_type: 'candidate_journey_tracking',
      description: 'Candidate journey tracking provides data on when each application choice progressed through the various steps in the candidate application journey.',
      class: SupportInterface::CandidateJourneyTrackingExport,
    },
    candidate_course_choice_withdrawal_survey: {
      name: 'Candidate course choice withdrawal survey',
      export_type: 'candidate_course_choice_withdrawal_survey',
      description: 'A list of candidates explanations for withdrawing a course choice. Also includes contact details for candidates who have agreed to be contacted.',
      class: SupportInterface::CourseChoiceWithdrawalSurveyExport,
    },
    equality_and_diversity: {
      name: 'Equality and diversity data',
      export_type: 'equality_and_diversity',
      description: 'Anonymised candidate equality and diversity data.',
      class: SupportInterface::EqualityAndDiversityExport,
    },
    find_feedback: {
      name: 'Find feedback',
      export_type: 'find_feedback',
      description: 'Feedback provided from the Find service results and course pages',
      class: SupportInterface::FindFeedbackExport,
    },
    interviews_export: {
      name: 'Interview changes',
      export_type: 'interview_export',
      description: 'A list of changes made to interviews for analysis of the Interviews feature',
      class: SupportInterface::InterviewChangesExport,
    },
    notes_export: {
      name: 'Notes',
      export_type: 'notes_export',
      description: 'Data related to notes made on applications by providers.',
      class: SupportInterface::NotesExport,
    },
    notification_preferences_export: {
      name: 'Notification preferences changes',
      export_type: 'notification_preferences_export',
      description: 'Changes to notification preferences for provider users.',
      class: SupportInterface::NotificationPreferencesExport,
    },
    notifications_export: {
      name: 'Notification preferences',
      export_type: 'notifications_export',
      description: 'Notification preferences for each provider user within each provider organisation.',
      class: SupportInterface::NotificationsExport,
    },
    offer_conditions: {
      name: 'Offer conditions',
      export_type: 'offer_conditions',
      description: 'A list of all offers showing offer conditions alongside the qualifications declared by the candidate. One line per offer.',
      class: SupportInterface::OfferConditionsExport,
    },
    organisation_permissions: {
      name: 'Organisational permissions changes',
      export_type: 'organisation_permissions',
      description: 'A list of changes to organisational permissions and audit information about the changes.',
      class: SupportInterface::OrganisationPermissionsExport,
    },
    provider_access_controls: {
      name: 'Provider permissions stats',
      export_type: 'provider_access_controls',
      description: "A list of providers and aggregated information about the number of users they have, their permissions, the changes that they\'ve made and their relationships to other organisations.",
      class: SupportInterface::ProviderAccessControlsExport,
    },
    providers_export: {
      name: 'Providers',
      export_type: 'providers_export',
      description: 'The list of providers from the Find service, along with when they signed the data sharing agreement.',
      class: SupportInterface::ProvidersExport,
    },
    persona_export: {
      name: 'Persona data',
      export_type: 'persona_export',
      description: 'A list of application choices with the associated postcodes for the candidate, provider and site. Also includes reasons for rejection, nationality and application status.',
      class: SupportInterface::PersonaExport,
    },
    qualifications: {
      name: 'Qualifications',
      export_type: 'qualifications',
      description: 'A list of qualifications for each application choice.',
      class: SupportInterface::QualificationsExport,
    },
    referee_survey: {
      name: 'Referee survey',
      export_type: 'referee_survey',
      description: 'This provides the compiled results of all the referee surveys.',
      class: SupportInterface::RefereeSurveyExport,
    },
    sites_export: {
      name: 'Sites',
      export_type: 'sites_export',
      description: 'A list of sites from Find, along with distances to their respective providers.',
      class: SupportInterface::SitesExport,
    },
    structured_reasons_for_rejection: {
      name: 'Structured reasons for rejection',
      export_type: 'structured_reasons_for_rejection',
      description: 'Structured reasons for rejection.',
      class: SupportInterface::StructuredReasonsForRejectionExport,
    },
    submitted_application_choices: {
      name: 'Submitted application choices',
      export_type: 'submitted_application_choices',
      description: 'The submitted application choices export provides data about which courses candidates applied to, as well as info about offers and candidate decisions.',
      class: SupportInterface::ApplicationChoicesExport,
    },
    tad_applications: {
      name: 'TAD applications',
      export_type: 'tad_applications',
      description: 'A list of all applications for TAD.',
      class: DataAPI::TADExport,
    },
    tad_provider_performance: {
      name: 'TAD provider performance',
      export_type: 'tad_provider_performance',
      description: 'A list of all application/offered/accepted counts for all courses in Apply.',
      class: SupportInterface::TADProviderStatsExport,
    },
    user_permissions: {
      name: 'User permissions changes',
      export_type: 'user_permissions',
      description: 'A list of changes to user permissions and audit information about the changes.',
      class: SupportInterface::UserPermissionsExport,
    },
    who_ran_which_export: {
      name: 'Who ran which export',
      export_type: 'who_ran_which_export',
      description: 'A list of all the exports that have been generated and who initiated them.',
      class: SupportInterface::WhoRanWhichExportExport,
    },
    work_history_break: {
      name: 'Work history break',
      export_type: 'work_history_break',
      description: 'A list of candidates with breaks in their work history.',
      class: SupportInterface::WorkHistoryBreakExport,
    },
  }.freeze

  belongs_to :initiator, polymorphic: true, optional: true
  audited except: [:data]

  def filename
    "#{name.parameterize}-#{created_at}.csv"
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

  enum export_type: {
    active_provider_user_permissions: 'active_provider_user_permissions',
    active_provider_users: 'active_provider_users',
    application_references: 'application_references',
    application_timings: 'application_timings',
    candidate_application_feedback: 'candidate_application_feedback',
    candidate_autosuggest_usage: 'candidate_autosuggest_usage',
    candidate_email_send_counts: 'candidate_email_send_counts',
    candidate_feedback: 'candidate_feedback',
    candidate_journey_tracking: 'candidate_journey_tracking',
    candidate_course_choice_withdrawal_survey: 'candidate_course_choice_withdrawal_survey',
    equality_and_diversity: 'equality_and_diversity',
    find_feedback: 'find_feedback',
    interviews_export: 'interview_export',
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
    tad_applications: 'tad_applications',
    tad_provider_performance: 'tad_provider_performance',
    user_permissions: 'user_permissions',
    who_ran_which_export: 'who_ran_which_export',
    work_history_break: 'work_history_break',
  }
end
