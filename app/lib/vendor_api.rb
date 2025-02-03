module VendorAPI
  extend VersioningHelpers

  VERSION_1_0 = '1.0'.freeze
  VERSION_1_1 = '1.1'.freeze
  VERSION_1_2 = '1.2'.freeze
  VERSION_1_3 = '1.3'.freeze
  VERSION_1_4 = '1.4'.freeze
  VERSION_1_5 = '1.5'.freeze
  VERSION_1_6 = '1.6'.freeze
  VERSION = VERSION_1_6

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
      Changes::ReferenceStatus,
      Changes::RefactoredReferenceOnApplication,
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
    '1.3' => [
      Changes::PreAcceptReferenceInformation,
      Changes::WorkHistory::AddRelevantSkillsBoolean,
      Changes::WorkHistory::AddStartAndEndMonth,
      Changes::WorkHistory::MarkDescriptionAsOptional,
      Changes::MarkPhaseAsDeprecated,
      Changes::RemoveReferencesWhenApplicationIsUnsuccessful,
      Changes::V13::AddReferenceReceivedToReference,
    ],
    '1.4' => [
      Changes::V14::AddGcseCompletingQualificationData,
    ],
    '1.5' => [
      Changes::V15::AddApplicationSentToProviderDatetime,
      Changes::V15::AddReferenceFeedbackProvidedAtDatetime,
    ],
    '1.6' => [
      Changes::V16::AddConfidentialToReference,
      Changes::V16::AddInactiveToApplicationAttributeStatuses,
    ],
  }.freeze
end
