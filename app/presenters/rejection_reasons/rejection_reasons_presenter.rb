##
# This presenter class supports serialized RejectionReasons data from the current iteration of structured rejection reasons.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
#
class RejectionReasons
  class RejectionReasonsPresenter < SimpleDelegator
    NO_GCSE_REJECTION_REASON_CODES = %w[no_maths_gcse no_english_gcse no_science_gcse].freeze
    PERSONAL_STATEMENT_REJECTION_REASON_CODES = %w[quality_of_writing personal_statement_other].freeze
    CLASS_ROOM_EXPERIENCE_REASON_CODES = %w[teaching_demonstration teaching_knowledge_other teaching_method_knowledge safeguarding_knowledge teaching_role_knowledge].freeze
    COMMUNICATION_OTHER_REASON_CODES = %w[could_not_arrange_interview did_not_reply communication_and_scheduling_other].freeze
    PLACEMENTS_REASON_CODES = %w[no_placements no_suitable_placements placements_other].freeze
    UNVERIFIED_QUALIFICATION_CODES = %w[unverified_equivalency_qualifications unverified_qualifications].freeze
    VALID_HIGH_LEVEL_ADVICE_REASON_CODES = %w[
      school_placement
      qualifications
      personal_statement
      teaching_knowledge
      communication_and_scheduling
      safeguarding
      visa_sponsorship
      course_full
      other
    ].freeze
    NO_TAILORED_ADVICE_CODES = %w[unsuitable_a_levels].freeze

    def rejection_reasons
      return {} unless structured_rejection_reasons&.any?

      reasons.each_with_object({}) do |reason, hash|
        hash[reason.label] = if reason.details&.text.present?
                               [reason.details.text]
                             elsif reason.selected_reasons
                               nested_reasons(reason)
                             else
                               [I18n.t("rejection_reasons.#{reason.id}.description")] # Course full
                             end
      end
    end

    def reasons
      @reasons ||= RejectionReasons.new(structured_rejection_reasons).selected_reasons
    end

    def nested_reasons(reason)
      reason.selected_reasons.each_with_object([]) do |nested_reason, ary|
        if nested_reason.details
          ary << "#{nested_reason.label_text}:" if render_label?(nested_reason.label, reason.selected_reasons)
          ary << nested_reason.details.text
        else
          ary << "#{nested_reason.label_text}."
        end
      end
    end

    def render_label?(label, nested_reasons)
      label != 'Other' || nested_reasons.size > 1
    end

    def tailored_advice_reasons
      return {} unless structured_rejection_reasons&.any?

      hash = {}
      reasons.each do |reason|
        hash[reason.id] = if reason.details&.text.present?
                            []
                          elsif reason.selected_reasons.present?
                            nested_advice_reasons(reason)
                          else
                            Array(valid_tailored_advice_reason_id(reason.id))
                          end
      end

      if hash.keys.include?('other') && hash.keys.include?('safeguarding')
        # Other and safeguarding are the same content, so we don't need to present both
        hash.delete('safeguarding')
      end

      hash.filter { |key, _value| key.in? VALID_HIGH_LEVEL_ADVICE_REASON_CODES }
    end

    def render_tailored_advice_section_headings?
      # Only render headings if there are multiple reasons given
      tailored_advice_reasons.keys.many? || tailored_advice_reasons.values&.first&.many?
    end

    def nested_advice_reasons(reason)
      reason.selected_reasons.map do |nested_reason|
        valid_tailored_advice_reason_id(nested_reason.id)
      end&.compact&.uniq
    end

    def valid_tailored_advice_reason_id(reason_id)
      return if reason_id.in? NO_TAILORED_ADVICE_CODES

      # We consolidate some nested reasons so we don't repeat the same advice.
      if reason_id.in? NO_GCSE_REJECTION_REASON_CODES
        'no_gcse'
      elsif reason_id.in? PERSONAL_STATEMENT_REJECTION_REASON_CODES
        'personal_statement_other'
      elsif reason_id.in? CLASS_ROOM_EXPERIENCE_REASON_CODES
        'teaching_knowledge_other'
      elsif reason_id.in? COMMUNICATION_OTHER_REASON_CODES
        'communication_and_scheduling_other'
      elsif reason_id.in? PLACEMENTS_REASON_CODES
        'placements_other'
      elsif reason_id.in? UNVERIFIED_QUALIFICATION_CODES
        'unverified_qualifications'
      else
        reason_id
      end
    end
  end
end
