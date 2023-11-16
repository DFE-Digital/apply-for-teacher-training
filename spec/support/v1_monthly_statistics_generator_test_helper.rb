class V1MonthlyStatisticsStubbedReport
  def to_h
    YAML.load_file(Rails.root.join('spec/support/v1_monthly_statistics.yaml'))
  end
end
