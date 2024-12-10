module CandidateInterface
  class WithdrawalReasonsForm
    include ActiveModel::Model
    CONFIG_PATH = 'config/new_withdrawal_reasons.yml'.freeze

    attr_accessor :reason, :comment
    validates :reason, presence: true
    validates :comment, presence: true, if: :other_reason?
    validates :comment, length: { maximum: 256 }

    def initial_options
      get_reasons('withdrawal_reasons')
    end

    def other_reason?
      reason == 'other'
    end

    def get_reasons(reason_group)
      reason = Struct.new(:id, :name, :text_area_label)
      (reasons.fetch(reason_group).keys.presence || []).map do |reason_id|
        reason.new(
          id: reason_id,
          name: translate("#{reason_id}.label"),
          text_area_label: reason_id == 'other' ? translate("#{reason_id}.comment.label") : nil,
        )
      end
    end

    def reasons
      @reasons ||= YAML.load_file(CONFIG_PATH)
    end

    def translate(string)
      string.gsub!('-', '_')
      I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
    end
  end
end
