module ProviderInterface
  class ReasonsForRejectionWizard
    include ActiveModel::Model

    class NestedAnswerValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return unless options.key?(:collection_name) && options.key?(:selected_option)

        top_level_question = options[:top_level_question]
        top_level_answer = record.send(top_level_question)

        record.errors.add(top_level_question, :blank) if top_level_answer.blank?
        record.errors.add(top_level_question, :inclusion) unless %w[Yes No].include?(top_level_answer)

        return unless record.send(top_level_question) == 'Yes'

        collection_values = record.send(options[:collection_name])
        if collection_values.blank?
          record.errors.add(options[:collection_name], :blank)
          return
        end

        if collection_values.include?(options[:selected_option])
          record.errors.add(attribute, :blank) if value.blank?
          record.errors.add(attribute, :too_long) if record.excessive_word_count?(value)
        end
      end
    end

    ReasonsForRejection::INITIAL_QUESTIONS.each do |top_level_question, children|
      children.each do |options_collection_name, options|
        next unless options.present? && options.is_a?(Hash)

        options.each do |option, attr_names|
          Array(attr_names).each do |attr_name|
            validates(
              attr_name,
              nested_answer: {
                top_level_question: top_level_question,
                collection_name: options_collection_name,
                selected_option: option.to_s,
              },
              on: :initial_questions,
            )
          end
        end
      end
    end

    attr_accessor :current_step, :checking_answers

    def initialize(state_store, attrs = {})
      @state_store = state_store

      remove_empty_strings_from_array_attributes!(attrs)
      clean_child_values_on_deselected_answers!(attrs)

      super(last_saved_state.deep_merge(attrs))

      # Once we get to the check answers page, this will be true for the rest of
      # the session
      @checking_answers = true if current_step == 'check'
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    def reason_not_captured_by_initial_questions?
      ReasonsForRejection::INITIAL_TOP_LEVEL_QUESTIONS.all? { |attr| send(attr) == 'No' }
    end

    def needs_other_reasons?
      honesty_and_professionalism_y_n == 'No' && safeguarding_y_n == 'No'
    end

    def next_step
      if current_step == 'initial_questions' && needs_other_reasons?
        'other_reasons'
      else
        'check'
      end
    end

    def save!
      clear_state!
    end

    attr_accessor :candidate_behaviour_y_n
    attr_writer :candidate_behaviour_what_did_the_candidate_do
    attr_accessor :candidate_behaviour_what_to_improve
    attr_accessor :candidate_behaviour_other

    def candidate_behaviour_what_did_the_candidate_do
      @candidate_behaviour_what_did_the_candidate_do || []
    end

    attr_accessor :quality_of_application_y_n
    attr_writer :quality_of_application_which_parts_needed_improvement
    attr_accessor :quality_of_application_personal_statement_what_to_improve
    attr_accessor :quality_of_application_subject_knowledge_what_to_improve
    attr_accessor :quality_of_application_other_details
    attr_accessor :quality_of_application_other_what_to_improve

    def quality_of_application_which_parts_needed_improvement
      @quality_of_application_which_parts_needed_improvement || []
    end

    attr_accessor :qualifications_y_n
    attr_writer :qualifications_which_qualifications
    attr_accessor :qualifications_other_details

    def qualifications_which_qualifications
      @qualifications_which_qualifications || []
    end

    attr_accessor :performance_at_interview_y_n
    attr_accessor :performance_at_interview_what_to_improve

    attr_accessor :course_full_y_n

    attr_accessor :offered_on_another_course_y_n
    attr_accessor :offered_on_another_course_details

    attr_accessor :honesty_and_professionalism_y_n
    attr_writer :honesty_and_professionalism_concerns
    attr_accessor :honesty_and_professionalism_concerns_information_false_or_inaccurate_details
    attr_accessor :honesty_and_professionalism_concerns_plagiarism_details
    attr_accessor :honesty_and_professionalism_concerns_references_details
    attr_accessor :honesty_and_professionalism_concerns_other_details

    def honesty_and_professionalism_concerns
      @honesty_and_professionalism_concerns || []
    end

    attr_accessor :safeguarding_y_n
    attr_writer :safeguarding_concerns
    attr_accessor :safeguarding_concerns_candidate_disclosed_information_details
    attr_accessor :safeguarding_concerns_vetting_disclosed_information_details
    attr_accessor :safeguarding_concerns_other_details

    def safeguarding_concerns
      @safeguarding_concerns || []
    end

    attr_accessor :other_advice_or_feedback_y_n
    attr_accessor :other_advice_or_feedback_details

    attr_accessor :why_are_you_rejecting_this_application

    with_options(on: :initial_questions) do
      validates :performance_at_interview_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :performance_at_interview_what_to_improve,
                presence: true,
                if: -> { performance_at_interview_y_n == 'Yes' }

      validates :course_full_y_n, presence: true, inclusion: { in: %w[Yes No] }

      validates :offered_on_another_course_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :offered_on_another_course_details,
                presence: true,
                if: -> { offered_on_another_course_y_n == 'Yes' }

      validates_each(:performance_at_interview_what_to_improve, :offered_on_another_course_details) do |record, attr, value|
        method = if attr == :performance_at_interview_what_to_improve
                   :performance_at_interview_y_n
                 else
                   :offered_on_another_course_y_n
                 end

        if record.send(method) == 'Yes'
          record.errors.add(attr, :blank) if value.blank?
          record.errors.add(attr, :too_long) if record.excessive_word_count?(value)
        end
      end
    end

    with_options(on: :other_reasons) do
      validates :other_advice_or_feedback_y_n,
                presence: true,
                inclusion: { in: %w[Yes No] }
      validates :other_advice_or_feedback_details,
                presence: true,
                if: -> { other_advice_or_feedback_y_n == 'Yes' }

      validates :why_are_you_rejecting_this_application,
                presence: true,
                if: :reason_not_captured_by_initial_questions?

      validates_each(:other_advice_or_feedback_details, :why_are_you_rejecting_this_application) do |record, attr, value|
        record.errors.add(attr, :too_long) if record.excessive_word_count?(value, 200)
      end
    end

    def excessive_word_count?(value, count = 100)
      value.present? && value.scan(/\w+/).size > count
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def to_model
      ReasonsForRejection.new(last_saved_state.except('current_step', 'checking_answers'))
    end

  private

    def clean_child_values_on_deselected_answers!(attrs)
      step = attrs[:current_step]
      clean_answers_for_initial_questions(attrs) if step == 'initial_questions'
      clean_answers_for_other_reasons(attrs) if step == 'other_reasons'

      other_reasons_unnecessary = last_saved_state.slice('honesty_and_professionalism_y_n', 'safeguarding_y_n').values.any?('Yes')
      unset_answers_for_other_reasons(attrs) if step == 'check' && other_reasons_unnecessary
    end

    def clean_answers_for_initial_questions(attrs)
      ReasonsForRejection::INITIAL_QUESTIONS.each_key { |k| clean_initial_question(attrs, k) }
    end

    def clean_initial_question(attrs, key)
      options_attribute_name, options = ReasonsForRejection::INITIAL_QUESTIONS[key].first
      # Clear the immediate child options if the Yes/No top level answer is No
      attrs.merge!(options_attribute_name => nil) if attrs[key] == 'No'

      if options.is_a?(Hash) && attrs.key?(options_attribute_name)
        options.each do |options_key, options_values|
          # Some options have multiple children to clear.
          Array(options_values).each do |child_attribute|
            # Clear each nested attribute unless the relevant key is present for the options collection attribute value.
            unless attrs[options_attribute_name]&.include?(options_key.to_s)
              attrs.merge!(child_attribute => nil)
            end
          end
        end
      end
    end

    def clean_answers_for_other_reasons(attrs)
      attrs[:other_advice_or_feedback_details] = nil if attrs[:other_advice_or_feedback_y_n] == 'No'
      answers_for_initial_top_level_questions = last_saved_state.slice(*ReasonsForRejection::INITIAL_TOP_LEVEL_QUESTIONS.map(&:to_s)).values
      attrs[:why_are_you_rejecting_this_application] = nil unless answers_for_initial_top_level_questions.uniq == %w[No]
    end

    def unset_answers_for_other_reasons(attrs)
      attrs[:why_are_you_rejecting_this_application] = nil
      attrs[:other_advice_or_feedback_y_n] = nil
      attrs[:other_advice_or_feedback_details] = nil
    end

    # Removes empty strings from array attributes, as they incorrectly pass presence validation
    def remove_empty_strings_from_array_attributes!(attrs)
      attrs.each do |k, v|
        attrs[k] = attrs[k].reject(&:blank?) if v.is_a?(Array)
      end
    end

    # The current state of the object, minus some ActiveModel cruft and
    # state_store, which is received fresh on each .new
    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end

    def last_saved_state
      saved_state = @state_store.read

      if saved_state
        JSON.parse(saved_state).except('interested_in_future_applications_y_n')
      else
        {}
      end
    end
  end
end
