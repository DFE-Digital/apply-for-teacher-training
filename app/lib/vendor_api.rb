module VendorAPI
  extend VersioningHelpers

  VERSION_1_0 = '1.0'.freeze
  VERSION = '1.1'.freeze

  VERSIONS = {
    '1.0' => [
      Changes::RetrieveApplications,
      Changes::RetrieveSingleApplication,
      Changes::MakeOffer,
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
      Changes::DeferOffer,
      Changes::ConfirmDeferredOffer,
      Changes::CreateNote,
      Changes::AddNotesToApplication,
      Changes::WithdrawOrDeclineApplication,
      Changes::AddInterviewsToApplication,
      Changes::CreateInterview,
      Changes::UpdateInterview,
      Changes::CancelInterview,
      Changes::Pagination,
      Changes::AddMetaToApplication,
    ],
  }.freeze
end
