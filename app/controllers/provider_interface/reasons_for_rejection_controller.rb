module ProviderInterface
  class ReasonsForRejectionController < ProviderInterfaceController
    def edit_initial_questions
      @wizard = ReasonsForRejectionWizard.new(session, current_step: 'initial_questions')
      @wizard.save_state!
    end

    def update_initial_questions
      @wizard = ReasonsForRejectionWizard.new(session, reasons_for_rejection_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_initial_questions
      end
    end

    def edit_other_reasons
      @wizard = ReasonsForRejectionWizard.new(session, current_step: 'other_reasons')
      @wizard.save_state!
    end

    def update_other_reasons
      @wizard = ReasonsForRejectionWizard.new(session, reasons_for_rejection_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_other_reasons
      end
    end

    def check
      @wizard = ReasonsForRejectionWizard.new(session, current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = ReasonsForRejectionWizard.new(session)
      @wizard.save!

      flash[:success] = 'Done!'
      redirect_to provider_interface_applications_path
    end

    def next_redirect(wizard)
      {
        'other_reasons' => { action: :edit_other_reasons },
        'check' => { action: :check },
      }.fetch(wizard.next_step)
    end

    def reasons_for_rejection_params
      params.require(:provider_interface_reasons_for_rejection)
        .permit(:candidate_behaviour_y_n, :candidate_behaviour_other,
                :candidate_behaviour_what_to_improve,
                :quality_of_application_y_n, :quality_of_application_personal_statement_what_to_improve,
                :quality_of_application_subject_knowledge_what_to_improve,
                :quality_of_application_other_details, :quality_of_application_other_what_to_improve,
                :qualifications_y_n, :qualifications_other_details,
                :performance_at_interview_y_n, :performance_at_interview_what_to_improve,
                :course_full_y_n,
                :offered_on_another_course_y_n,
                :honesty_and_professionalism_y_n, :honesty_and_professionalism_concerns_other_details,
                :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                :honesty_and_professionalism_concerns_plagiarism_details,
                :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                :safeguarding_y_n,
                :safeguarding_concerns_candidate_disclosed_information_details,
                :safeguarding_concerns_vetting_disclosed_information_details,
                :safeguarding_concerns_other_details,
                :other_advice_or_feedback_y_n,
                :other_advice_or_feedback_details,
                :interested_in_future_applications_y_n,
                :why_are_you_rejecting_this_application,
                honesty_and_professionalism_concerns: [],
                safeguarding_concerns: [],
                qualifications_which_qualifications: [],
                quality_of_application_which_parts_needed_improvement: [],
                candidate_behaviour_what_did_the_candidate_do: [])
    end
  end

  class ReasonsForRejection
    include ActiveModel::Model

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

    def to_prose
      safeguarding_y_n.to_s
    end
  end

  class ReasonsForRejectionWizard
    include ActiveModel::Model

    STATE_STORE_KEY = :reasons_for_rejection

    attr_accessor :current_step, :checking_answers

    delegate :to_prose, to: :to_model

    def initialize(state_store, attrs = {})
      @state_store = state_store
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

    with_options(on: :other_reasons) do |other_reasons|
      other_reasons.validates :other_advice_or_feedback_y_n, presence: true, inclusion: { in: %w[Yes No] }
      other_reasons.validates :other_advice_or_feedback_details,
                              presence: true,
                              if: -> { other_advice_or_feedback_y_n == 'Yes' }

      other_reasons.validates :interested_in_future_applications_y_n, presence: true, inclusion: { in: %w[Yes No] }

      other_reasons.validates :why_are_you_rejecting_this_application,
                              presence: true,
                              if: :reason_not_captured_by_initial_questions?
    end

    with_options(on: :initial_questions) do |initial_questions|
      initial_questions.validates :offered_on_another_course_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :candidate_behaviour_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :candidate_behaviour_what_did_the_candidate_do,
                                  presence: true,
                                  if: -> { candidate_behaviour_y_n == 'Yes' }
      initial_questions.validates :candidate_behaviour_other,
                                  presence: true,
                                  if: -> { candidate_behaviour_what_did_the_candidate_do.include?('other') }
      initial_questions.validates :candidate_behaviour_what_to_improve,
                                  presence: true,
                                  if: -> { candidate_behaviour_what_did_the_candidate_do.include?('other') }

      initial_questions.validates :quality_of_application_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :quality_of_application_which_parts_needed_improvement,
                                  presence: true,
                                  if: -> { quality_of_application_y_n == 'Yes' }
      initial_questions.validates :quality_of_application_personal_statement_what_to_improve,
                                  presence: true,
                                  if: -> { quality_of_application_which_parts_needed_improvement.include?('personal_statement') }
      initial_questions.validates :quality_of_application_subject_knowledge_what_to_improve,
                                  presence: true,
                                  if: -> { quality_of_application_which_parts_needed_improvement.include?('subject_knowledge') }
      initial_questions.validates :quality_of_application_other_details,
                                  presence: true,
                                  if: -> { quality_of_application_which_parts_needed_improvement.include?('other') }
      initial_questions.validates :quality_of_application_other_what_to_improve,
                                  presence: true,
                                  if: -> { quality_of_application_which_parts_needed_improvement.include?('other') }

      initial_questions.validates :qualifications_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :qualifications_which_qualifications,
                                  presence: true,
                                  if: -> { qualifications_y_n == 'Yes' }
      initial_questions.validates :qualifications_other_details,
                                  presence: true,
                                  if: -> { qualifications_which_qualifications.include?('other') }

      initial_questions.validates :performance_at_interview_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :performance_at_interview_what_to_improve,
                                  presence: true,
                                  if: -> { qualifications_y_n == 'Yes' }

      initial_questions.validates :course_full_y_n, presence: true, inclusion: { in: %w[Yes No] }

      initial_questions.validates :honesty_and_professionalism_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :honesty_and_professionalism_concerns,
                                  presence: true,
                                  if: -> { honesty_and_professionalism_y_n == 'Yes' }
      initial_questions.validates :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                                  presence: true,
                                  if: -> { honesty_and_professionalism_concerns.include?('information_false_or_inaccurate') }
      initial_questions.validates :honesty_and_professionalism_concerns_plagiarism_details,
                                  presence: true,
                                  if: -> { honesty_and_professionalism_concerns.include?('plagiarism') }
      initial_questions.validates :honesty_and_professionalism_concerns_references_details,
                                  presence: true,
                                  if: -> { honesty_and_professionalism_concerns.include?('references') }
      initial_questions.validates :honesty_and_professionalism_concerns_other_details,
                                  presence: true,
                                  if: -> { honesty_and_professionalism_concerns.include?('other') }
      initial_questions.validates :safeguarding_y_n, presence: true, inclusion: { in: %w[Yes No] }
      initial_questions.validates :safeguarding_concerns,
                                  presence: true,
                                  if: -> { safeguarding_y_n == 'Yes' }
      initial_questions.validates :safeguarding_concerns_candidate_disclosed_information_details,
                                  presence: true,
                                  if: -> { safeguarding_concerns.include?('candidate_disclosed_information') }
      initial_questions.validates :safeguarding_concerns_vetting_disclosed_information_details,
                                  presence: true,
                                  if: -> { safeguarding_concerns.include?('vetting_disclosed_information') }
      initial_questions.validates :safeguarding_concerns_other_details,
                                  presence: true,
                                  if: -> { safeguarding_concerns.include?('other') }
    end

  private

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
