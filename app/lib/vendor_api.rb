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
      Changes::RegenerateTestData,
      Changes::PingEndpoint,
      Changes::ExperimentalClearTestData,
      Changes::ExperimentalGenerateTestData,
    ],
    '1.1' => [],
    '1.2' => [],
  }.freeze

  def self.draft_version
    @draft_version ||= VERSIONS.keys.sort.find { |version| version > VERSION }
  end

  def self.previous_version(current_version)
    @previous_version ||= VERSIONS.keys.sort.reverse.find { |version| version < current_version }
  end
end
