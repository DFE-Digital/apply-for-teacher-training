module CandidateInterface
  module WithdrawalReasons
    class PrimaryReasonsForm
      include ActiveModel::Model

      attr_accessor :primary_reason, :comment, :id

      validates :primary_reason, presence: true
      validates :comment, presence: true, if: :other?
      validates :comment, word_count: { maximum: 200 }

      def self.build_from_reason(withdraw_reason)
        new(
          {
            primary_reason: withdraw_reason.reason.split('.').first,
            comment: withdraw_reason.comment,
            id: withdraw_reason.id,
          },
          application_choice: withdraw_reason.application_choice,
        )
      end

      def initialize(attributes = {}, application_choice: nil)
        @application_choice = application_choice
        super(attributes)
      end

      def can_save?
        valid? && other?
      end

      def save!
        if id.present?
          withdrawal_reason = @application_choice.withdrawal_reasons.find(id)
          withdrawal_reason.update!(reason: primary_reason, comment:)
          withdrawal_reason
        else
          @application_choice.withdrawal_reasons.create!(reason: primary_reason, comment:)
        end
      end

      def reason_options
        option = Struct.new(:id, :name, :text_area_label)
        WithdrawalReason.find_reason_options.keys.map do |reason|
          option.new(
            id: reason,
            name: translate("#{reason}.label"),
            text_area_label: reason == 'other' ? translate("#{reason}.comment.label") : nil,
          )
        end
      end

      def primary_reason_text
        [translate("#{primary_reason}.label"), comment].join(': ')
      end

    private

      def other?
        primary_reason == 'other'
      end

      def translate(string)
        string.gsub!('-', '_')
        I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
      end
    end
  end
end
