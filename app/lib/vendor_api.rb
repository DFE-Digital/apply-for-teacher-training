module VendorAPI
  VERSION = '1.0'.freeze

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
      Changes::PingEndpoint,
    ],
  }.freeze
end
