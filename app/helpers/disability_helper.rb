module DisabilityHelper
  STANDARD_DISABILITIES = %w[blind deaf learning long_standing mental physical social].map { |disability|
    [disability, I18n.t("equality_and_diversity.disabilities.#{disability}.label")]
  }.freeze
end
