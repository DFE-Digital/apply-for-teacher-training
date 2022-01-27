module Publications
  class CompareMinisterialReports
    def initialize(bat_data:, tad_data:)
      @bat_data = bat_data
      @tad_data = tad_data
    end

    def diff
      result = {}
      @bat_data.each do |subject, data|
        result[subject.to_sym] ||= {}
        data.each do |status, ids|
          result[subject.to_sym][status.to_sym] = { only_bat: ids, bat_total: ids.count }
        end
      end
      @tad_data.each do |subject, data|
        if result[subject.to_sym]
          data.each do |status, ids|
            puts "merge_ids for #{subject} #{status}"
            merge_ids(
              result[subject.to_sym],
              status,
              ids
            )
          end
          result[subject.to_sym] = nil if no_differences?(result[subject.to_sym])
        else
          result[subject.to_sym] = nil
        end
      end
      result
    end

  private

    def no_differences?(subject_result)
      subject_result.all? do |_status, status_result|
        status_result[:only_tad].nil? && status_result[:only_bat].nil?
      end
    end

    def merge_ids(result, status, tad_ids)
      result[status.to_sym] ||= { only_bat: nil, bat_total: 0 }
      result[status.to_sym][:tad_total] = tad_ids.count
      only_bat = (result[status.to_sym][:only_bat] || []) - (tad_ids || [])
      only_tad = (tad_ids || []) - (result[status.to_sym][:only_bat] || [])
      result[status.to_sym][:only_bat] = only_bat.present? ? only_bat : nil
      result[status.to_sym][:only_tad] = only_tad.present? ? only_tad : nil
      result
    end
  end
end
