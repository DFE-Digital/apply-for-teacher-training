class SafeguardingStatus
  attr_reader :status, :i18n_key

  def initialize(status:, i18n_key:)
    @status = status
    @i18n_key = i18n_key
  end

  def message
    I18n.t("#{i18n_key}.#{status}")
  end
end
