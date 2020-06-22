module ProviderInterface
  class RejectionReasonsForm
    include ActiveModel::Model

    attr_writer :questions
    attr_accessor :alternative_rejection_reason
    validates :alternative_rejection_reason, presence: true, if: -> { all_answers_no? }
    validate :questions_all_valid?

    STEP_1_QUESTION_COUNT = 8

    def self.questions
      @questions ||= YAML.load_file(Rails.root.join('config/rejection_reasons_questions.yml'))
    end

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

    def interested_in_future_applications?
      answered_questions.find { |q| q.label.include?('future_applications') }.y_or_n == 'Y'
    end

    def step_2_questions?
      @answered_questions.count == STEP_1_QUESTION_COUNT && last_2_answers_no?
    end

    def last_2_answers_no?
      answered_questions.map(&:y_or_n).flatten.last(2).include?('N')
    end

    def questions_for_current_step
      if answered_questions.count.zero?
        self.class.questions.take(STEP_1_QUESTION_COUNT)
      elsif step_2_questions?
        self.class.questions.drop(STEP_1_QUESTION_COUNT)
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
