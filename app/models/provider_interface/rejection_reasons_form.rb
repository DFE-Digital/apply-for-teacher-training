module ProviderInterface
  class RejectionReasonsForm
    include ActiveModel::Model

    QUESTIONS = [
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.candidate_behaviour.label',
        additional_question: 'rejection_resons.questions.candidate_behaviour.additional_question',
        reasons: [
          RejectionReasonReason.new(label: 'rejection_resons.reasons.candidate_behaviour.didnt_reply_to_our_interview_offer'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.candidate_behaviour.didnt_attend_interview'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.other', textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.details.label'),
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.advice.label'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.quality_of_their_application.label',
        additional_question: 'rejection_resons.questions.quality_of_their_application.additional_question',
        reasons: [
          RejectionReasonReason.new(label: 'rejection_resons.reasons.quality_of_their_application.personal_statement'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.quality_of_their_application.subject_knowledge'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.other', textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.advice.label'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.qualifications.label',
        additional_question: 'rejection_resons.questions.qualifications.additional_question',
        reasons: [
          RejectionReasonReason.new(label: 'rejection_resons.reasons.qualifications.no_maths'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.qualifications.no_english'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.qualifications.no_science'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.qualifications.no_degree'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.qualifications.degree_doesnt_meet_course_requiremnets'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.other', textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.details.label'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.performance_at_interview.label',
        reasons: [
          RejectionReasonReason.new(textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.details.label'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(label: 'rejection_resons.questions.course_is_full.label'),
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.offered_them_a_place_on_another_course.label',
      ),
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.concerns_about_honesty_and_professionalism.label',
        additional_question: 'rejection_resons.questions.concerns_about_honesty_and_professionalism.additional_question',
        reasons: [
          RejectionReasonReason.new(label: 'rejection_resons.reasons.concerns_about_honesty_and_professionalism.false_or_inaccurate_information'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.concerns_about_honesty_and_professionalism.plagiarism'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.concerns_about_honesty_and_professionalism.references_didnt_support_application'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.other', textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.details.label'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.safeguarding.label',
        additional_question: 'rejection_resons.questions.safeguarding.additional_question',
        reasons: [
          RejectionReasonReason.new(label: 'rejection_resons.reasons.safeguarding.information_disclosed'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.safeguarding.vetting_process'),
          RejectionReasonReason.new(label: 'rejection_resons.reasons.other', textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.details.label'),
          ]),
        ],
      ),

      # STEP 2
      RejectionReasonQuestion.new(
        label: 'rejection_resons.questions.any_other_advice.label',
        reasons: [
          RejectionReasonReason.new(textareas: [
            RejectionReasonTextarea.new(label: 'rejection_resons.text_area.details.label'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(label: 'rejection_resons.questions.future_applications.label'),
    ].freeze

    attr_writer :questions
    attr_accessor :alternative_rejection_reason
    validates :alternative_rejection_reason, presence: true, if: -> { all_answers_no? }
    validate :questions_all_valid?

    def initialize(*args)
      super(*args)
      assign_answered_questions
    end

    def questions
      @questions || []
    end

    def answered_questions
      @answered_questions || []
    end

    def assign_answered_questions
      @answered_questions, @questions = questions.partition(&:answered)
    end

    def next_step!
      @answered_questions = answered_questions + questions
      @questions = questions_for_current_step
    end

    def all_answers_no?
      answered_questions.map(&:y_or_n).flatten.uniq == %w[N]
    end

    def questions_for_current_step
      if answered_questions.count.zero?
        QUESTIONS.take(8)
      elsif answered_questions.map(&:y_or_n).flatten.last(2).include?('N')
        QUESTIONS.drop(8)
      else
        []
      end
    end

    alias_method :begin!, :next_step!

    def done?
      @answered_questions.any? && @questions.empty?
    end

    def questions_all_valid?
      questions.each_with_index do |q, i|
        next unless q.invalid?

        q.errors.each do |attr, message|
          errors.add("questions[#{i}].#{attr}", message)
        end
      end
    end

    def questions_attributes=(attributes)
      @questions ||= []
      attributes.each do |_id, q|
        @questions.push(RejectionReasonQuestion.new(q))
      end
    end
  end
end
