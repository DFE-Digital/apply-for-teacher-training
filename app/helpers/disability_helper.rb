module DisabilityHelper
  STANDARD_DISABILITIES = %w[
    social
    blind
    development_condition
    deaf
    learning
    long_standing
    mental
    physical
  ].map do |disability|
    [disability, I18n.t("equality_and_diversity.disabilities.#{disability}.label")]
  end.freeze
end
