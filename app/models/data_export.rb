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
      description: 'This provides the compiled results of all the referee surveys',
      class: SupportInterface::RefereeSurveyExport,
    },
    candidate_survey: {
      name: 'Candidate survey',
      description: 'This provides the compiled results of all the candidate satisfaction surveys',
      class: SupportInterface::CandidateSurveyExport,
    },
    active_provider_users: {
      name: 'Active provider users',
      description: 'The list of provider users that have signed in to apply at least once.',
      class: SupportInterface::ActiveProviderUsersExport,
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
