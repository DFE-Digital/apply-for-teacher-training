module ProviderInterface
  class ReasonsForRejectionWizard
    include ActiveModel::Model

    STATE_STORE_KEY = :reasons_for_rejection

    attr_accessor :current_step, :checking_answers

    delegate :to_prose, to: :to_model

    def initialize(state_store, attrs = {})
      @state_store = state_store

      # Remove empty strings from array attributes, they pass presence validation
      remove_empty_strings_from_array_attributes!(attrs)

      super(last_saved_state.deep_merge(attrs))

      # Once we get to the check answers page, this will be true for the rest of
      # the session
      @checking_answers = true if current_step == 'check'
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    def reason_not_captured_by_initial_questions?
      %i[
        candidate_behaviour_y_n
        quality_of_application_y_n
        qualifications_y_n
        performance_at_interview_y_n
        offered_on_another_course_y_n
        honesty_and_professionalism_y_n
        safeguarding_y_n
      ].all? { |attr| send(attr) == 'No' }
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

    def to_model
      ReasonsForRejection.new(state.except('current_step', 'checking_answers'))
    end

    def save_state!
      @state_store[STATE_STORE_KEY] = state.to_json
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

    attr_accessor :interested_in_future_applications_y_n

    attr_accessor :why_are_you_rejecting_this_application

    with_options(on: :other_reasons) do
      validates :other_advice_or_feedback_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :other_advice_or_feedback_details,
                presence: true,
                if: -> { other_advice_or_feedback_y_n == 'Yes' }

      validates :interested_in_future_applications_y_n, presence: true, inclusion: { in: %w[Yes No] }

      validates :why_are_you_rejecting_this_application,
                presence: true,
                if: :reason_not_captured_by_initial_questions?
    end

    with_options(on: :initial_questions) do
      validates :candidate_behaviour_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :candidate_behaviour_what_did_the_candidate_do,
                presence: true,
                if: -> { candidate_behaviour_y_n == 'Yes' }
      validates :candidate_behaviour_other,
                presence: true,
                if: -> { candidate_behaviour_what_did_the_candidate_do.include?('other') }
      validates :candidate_behaviour_what_to_improve,
                presence: true,
                if: -> { candidate_behaviour_what_did_the_candidate_do.include?('other') }

      validates :quality_of_application_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :quality_of_application_which_parts_needed_improvement,
                presence: true,
                if: -> { quality_of_application_y_n == 'Yes' }
      validates :quality_of_application_personal_statement_what_to_improve,
                presence: true,
                if: -> { quality_of_application_which_parts_needed_improvement.include?('personal_statement') }
      validates :quality_of_application_subject_knowledge_what_to_improve,
                presence: true,
                if: -> { quality_of_application_which_parts_needed_improvement.include?('subject_knowledge') }
      validates :quality_of_application_other_details,
                presence: true,
                if: -> { quality_of_application_which_parts_needed_improvement.include?('other') }
      validates :quality_of_application_other_what_to_improve,
                presence: true,
                if: -> { quality_of_application_which_parts_needed_improvement.include?('other') }

      validates :qualifications_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :qualifications_which_qualifications,
                presence: true,
                if: -> { qualifications_y_n == 'Yes' }
      validates :qualifications_other_details,
                presence: true,
                if: -> { qualifications_which_qualifications.include?('other') }

      validates :performance_at_interview_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :performance_at_interview_what_to_improve,
                presence: true,
                if: -> { qualifications_y_n == 'Yes' }

      validates :course_full_y_n, presence: true, inclusion: { in: %w[Yes No] }

      validates :offered_on_another_course_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :offered_on_another_course_details,
                presence: true,
                if: -> { offered_on_another_course_y_n == 'Yes' }

      validates :honesty_and_professionalism_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :honesty_and_professionalism_concerns,
                presence: true,
                if: -> { honesty_and_professionalism_y_n == 'Yes' }
      validates :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                presence: true,
                if: -> { honesty_and_professionalism_concerns.include?('information_false_or_inaccurate') }
      validates :honesty_and_professionalism_concerns_plagiarism_details,
                presence: true,
                if: -> { honesty_and_professionalism_concerns.include?('plagiarism') }
      validates :honesty_and_professionalism_concerns_references_details,
                presence: true,
                if: -> { honesty_and_professionalism_concerns.include?('references') }
      validates :honesty_and_professionalism_concerns_other_details,
                presence: true,
                if: -> { honesty_and_professionalism_concerns.include?('other') }
      validates :safeguarding_y_n, presence: true, inclusion: { in: %w[Yes No] }
      validates :safeguarding_concerns,
                presence: true,
                if: -> { safeguarding_y_n == 'Yes' }
      validates :safeguarding_concerns_candidate_disclosed_information_details,
                presence: true,
                if: -> { safeguarding_concerns.include?('candidate_disclosed_information') }
      validates :safeguarding_concerns_vetting_disclosed_information_details,
                presence: true,
                if: -> { safeguarding_concerns.include?('vetting_disclosed_information') }
      validates :safeguarding_concerns_other_details,
                presence: true,
                if: -> { safeguarding_concerns.include?('other') }
    end

    def feedback_heading
      if interested_in_future_applications_y_n == 'Yes'
        'The provider would be interested in future applications from you'
      else
        'Training provider feedback'
      end
    end

  private

    def remove_empty_strings_from_array_attributes!(attrs)
      attrs.each do |k, v|
        attrs[k] = attrs[k].reject(&:blank?) if v.is_a?(Array)
      end
    end

    # The current state of the object, minus some ActiveModel cruft and
    # state_store, which is received fresh on each .new
    def state
      as_json(except: %w[state_store errors validation_context])
    end

    def last_saved_state
      JSON.parse(@state_store[STATE_STORE_KEY].presence || '{}')
    end

    def clear_state!
      @state_store.delete(STATE_STORE_KEY)
    end
  end
end
