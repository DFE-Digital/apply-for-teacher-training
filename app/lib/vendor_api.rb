module VendorAPI
  extend VersioningHelpers

  VERSION_1_0 = '1.0'.freeze
  VERSION_1_1 = '1.1'.freeze
  VERSION_1_2 = '1.2'.freeze
  VERSION = VERSION_1_2

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
    '1.1' => [
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
    '1.2' => [
      Changes::RejectByCodes,
      Changes::RejectionReasonCodes,
      Changes::Add2023HesaToApplication,
    ],
    '1.3pre' => [
      Changes::PreAcceptReferenceInformation,
    ],
  }.freeze
end
