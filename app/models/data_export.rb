class DataExport < ApplicationRecord
  EXPORT_TYPES = {
    application_timings: {
      name: 'Application timings',
      description: 'The application timings provides data on when an application form attribute was last updated by the candidate.',
      class: SupportInterface::ApplicationsExport,
    },
    submitted_application_choices: {
      name: 'Submitted application choices',
      description: 'The submitted application choices export provides data about which courses candidates applied to, as well as info about offers and candidate decisions.',
      class: SupportInterface::ApplicationChoicesExport,
    },
    candidate_journey_tracking: {
      name: 'Candidate journey tracking',
      description: 'Candidate journey tracking provides data on when each application choice progressed through the various steps in the candidate application journey.',
      class: SupportInterface::CandidateJourneyTrackingExport,
    },
    providers_export: {
      name: 'Providers',
      description: 'The list of providers that are being synced from the Find service, along with when they signed the data sharing agreement.',
      class: SupportInterface::ProvidersExport,
    },
    referee_survey: {
      name: 'Referee survey',
      description: 'This provides the compiled results of all the referee surveys.',
      class: SupportInterface::RefereeSurveyExport,
    },
    candidate_application_feedback: {
      name: 'Candidate application feedback',
      description: 'This provides the compiled results of all feedback received from prompts throughout the application form.',
      class: SupportInterface::CandidateApplicationFeedbackExport,
    },
    candidate_feedback: {
      name: 'Candidate feedback',
      description: 'This provides the compiled results of all the single-page candidate feedback forms.',
      class: SupportInterface::CandidateFeedbackExport,
    },
    active_provider_users: {
      name: 'Active provider users',
      description: 'The list of provider users that have signed in to apply at least once.',
      class: SupportInterface::ActiveProviderUsersExport,
    },
    active_provider_user_permissions: {
      name: 'Active provider user permissions',
      description: 'The list of provider users with the permissions they have for each of their organisations.',
      class: SupportInterface::ActiveProviderUserPermissionsExport,
    },
    course_choice_withdrawal: {
      name: 'Candidate course choice withdrawal survey',
      description: 'A list of candidates explanations for withdrawing a course choice. Also includes contact details for candidates who have agreed to be contacted.',
      class: SupportInterface::CourseChoiceWithdrawalSurveyExport,
    },
    tad_provider_performance: {
      name: 'Provider performance for TAD',
      description: 'A list of all application/offered/accepted counts for all courses in Apply.',
      class: SupportInterface::TADProviderStatsExport,
    },
    offer_conditions: {
      name: 'Offer conditions',
      description: 'A list of all offers showing offer conditions alongside the qualifications declared by the candidate. One line per offer.',
      class: SupportInterface::OfferConditionsExport,
    },
    application_references: {
      name: 'Application references',
      description: 'A list of all application references which have been selected by candidates to date.',
      class: SupportInterface::ApplicationReferencesExport,
    },
    tad_applications: {
      name: 'Applications for TAD',
      description: 'A list of all applications for TAD.',
      class: SupportInterface::TADExport,
    },
    equality_and_diversity: {
      name: 'Equality and diversity data',
      description: 'Anonymised candidate equality and diversity data.',
      class: SupportInterface::EqualityAndDiversityExport,
    },
    unexplained_breaks_in_work_history: {
      name: 'Unexplained breaks in work history',
      description: 'A list of candidates with unexplained breaks in their work history.',
      class: SupportInterface::UnexplainedBreaksInWorkHistoryExport,
    },
    provider_access_controls: {
      name: 'Provider Access Controls',
      description: 'A list of providers and information about their permissions',
      class: SupportInterface::ProviderAccessControlsExport,
    },
    locations_export: {
      name: 'Locations',
      description: 'A list of application choices with the associated postcodes for the candidate, provider and site.',
      class: SupportInterface::LocationsExport,
    },
    sites_export: {
      name: 'Sites',
      description: 'A list of sites that are being synced from Find, along with distances to their respective providers',
      class: SupportInterface::SitesExport,
    },
    qualifications: {
      name: 'Qualifications',
      description: 'A list of qualifications for each application choice',
      class: SupportInterface::QualificationsExport,
    },
    notifications_export: {
      name: 'Notifications',
      description: 'Data to enable performance assesment of Notification feature',
      class: SupportInterface::NotificationsExport,
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
end
