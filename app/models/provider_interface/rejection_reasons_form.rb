module ProviderInterface
  class RejectionReasonsForm
    include ActiveModel::Model

    QUESTIONS = [
      RejectionReasonQuestion.new(
        label: 'Was it related to candidate behaviour?',
        additional_question: 'What did the candidate do?',
        reasons: [
          RejectionReasonReason.new(label: 'Didn’t reply to our interview offer'),
          RejectionReasonReason.new(label: 'Didn’t attend interview'),
          RejectionReasonReason.new(label: 'Other', textareas: %i[explanation advice]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to the quality of their application?',
        additional_question: 'Which parts of the application needed improvement?',
        reasons: [
          RejectionReasonReason.new(label: 'Personal statement'),
          RejectionReasonReason.new(label: 'Subject knowledge'),
          RejectionReasonReason.new(label: 'Other', textareas: [:advice]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to qualifications?',
        additional_question: 'Which qualifications?',
        reasons: [
          RejectionReasonReason.new(label: 'No Maths GCSE grade 4 (C) or above, or valid equivalent'),
          RejectionReasonReason.new(label: 'Other', textareas: [:explanation]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to their performance at interview?',
        reasons: [
          RejectionReasonReason.new(textareas: [:explanation]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Is there any other advice or feedback you’d like to give?',
        reasons: [
          RejectionReasonReason.new(label: 'Please give details', textareas: [:explanation]),
        ],
      ),
    ].freeze

    attr_writer :questions
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

    def questions_for_current_step
      if answered_questions.count.zero?
        QUESTIONS.take(4)
      elsif answered_questions.map(&:y_or_n).flatten.last(2).include?('N')
        QUESTIONS.drop(4)
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
