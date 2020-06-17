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
          RejectionReasonReason.new(label: 'Other', textareas: [
            RejectionReasonTextarea.new(label: 'Please give details'),
            RejectionReasonTextarea.new(label: 'What could they do to improve?'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to the quality of their application?',
        additional_question: 'Which parts of the application needed improvement?',
        reasons: [
          RejectionReasonReason.new(label: 'Personal statement'),
          RejectionReasonReason.new(label: 'Subject knowledge'),
          RejectionReasonReason.new(label: 'Other', textareas: [
            RejectionReasonTextarea.new(label: 'What could they do to improve?'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to qualifications?',
        additional_question: 'Which qualifications?',
        reasons: [
          RejectionReasonReason.new(label: 'No Maths GCSE grade 4 (C) or above, or valid equivalent'),
          RejectionReasonReason.new(label: 'Other', textareas: [
            RejectionReasonTextarea.new(label: 'Please give details'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to their performance at interview?',
        reasons: [
          RejectionReasonReason.new(textareas: [
            RejectionReasonTextarea.new(label: 'Please give details'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(label: 'Was it because this course is full?'),
      RejectionReasonQuestion.new(
        label: 'Was it because you offered them a place on another course?',
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to concerns about the candidate’s honesty and professionalism?',
        additional_question: 'What concerns did you have?',
        reasons: [
          RejectionReasonReason.new(label: 'Information given on application form false or inaccurate'),
          RejectionReasonReason.new(label: 'Evidence of plagiarism in personal statement or elsewhere'),
          RejectionReasonReason.new(label: 'References didn’t support application'),
          RejectionReasonReason.new(label: 'Other', textareas: [
            RejectionReasonTextarea.new(label: 'Please give details'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(
        label: 'Was it related to safeguarding?',
        additional_question: 'Which safeguarding issues in particular?',
        reasons: [
          RejectionReasonReason.new(label: 'Information disclosed by candidate makes them unsuitable to work with children'),
          RejectionReasonReason.new(label: 'Information revealed by our vetting process makes the candidate unsuitable to work with children'),
          RejectionReasonReason.new(label: 'Other', textareas: [
            RejectionReasonTextarea.new(label: 'Please give details'),
          ]),
        ],
      ),

      # STEP 2
      RejectionReasonQuestion.new(
        label: 'Is there any other advice or feedback you’d like to give?',
        reasons: [
          RejectionReasonReason.new(label: 'Please give details', textareas: [
            RejectionReasonTextarea.new(label: 'Please give details'),
          ]),
        ],
      ),
      RejectionReasonQuestion.new(label: 'Would you be interested in future applications from !TODO!?'),
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
