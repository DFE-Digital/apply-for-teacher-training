module DisabilityHelper
  STANDARD_DISABILITIES = %w[blind deaf development learning long_standing mental physical social].map do |disability|
    [disability, I18n.t("equality_and_diversity.disabilities.#{disability}.label")]
  end.freeze
end
