module VendorAPI
  extend VersioningHelpers

  PRELIMINARY_VERSION = '1.0'.freeze
  VERSION = PRELIMINARY_VERSION

  VERSIONS = {
    '1.0' => [
      Changes::RetrieveApplications,
      Changes::RetrieveSingleApplication,
      Changes::MakeAnOffer,
      Changes::ConfirmEnrolment,
      Changes::ConfirmConditionsMet,
      Changes::ConditionsNotMet,
      Changes::RejectApplication,
      Changes::GcseSubjects,
      Changes::GcseGrades,
      Changes::AAndAsLevelSubjects,
      Changes::AAndAsLevelGrades,
      Changes::GenerateTestData,
      Changes::ClearTestData,
      Changes::RegenerateTestData,
      Changes::PingEndpoint,
      Changes::ExperimentalClearTestData,
      Changes::ExperimentalGenerateTestData,
    ],
    '1.1pre' => [
      Changes::DeferAnOffer,
      Changes::ConfirmADeferredOffer,
      Changes::CreateNote,
      Changes::NotesForApplication,
      Changes::WithdrawOrDeclineApplication,
      Changes::AddInterviewsToApplication,
      Changes::CreateInterview,
      Changes::UpdateInterview,
      Changes::CancelInterview,
      Changes::Pagination,
      Changes::ApplicationMeta,
    ],
  }.freeze
end
