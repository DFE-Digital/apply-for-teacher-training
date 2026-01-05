require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormPresenter do
  include Rails.application.routes.url_helpers

  describe 'delegating methods to application form' do
    let(:application_form_spy) { spy }

    %i[
      apply_2?
      cache_key_with_version
      candidate_has_previously_applied?
      english_main_language
      first_name
      first_nationality
      previous_application_form
      phase
      personal_details_completed
      support_reference
    ].each do |method|
      it "delegates '##{method}' to the application form" do
        described_class.new(application_form_spy).send(method)

        expect(application_form_spy).to have_received(method)
      end
    end
  end

  describe '#degrees_path' do
    let(:presenter) { described_class.new(application_form) }

    context 'when there are no degrees and the degree is not completed' do
      let(:application_form) do
        create(
          :application_form,
          application_qualifications: [],
          degrees_completed: false,
          recruitment_cycle_year: 2025,
        )
      end

      it 'returns the university degree path' do
        expect(presenter.degrees_path).to eq(Rails.application.routes.url_helpers.candidate_interface_degree_university_degree_path)
      end
    end

    context 'when there are degrees or the degree is completed' do
      let(:application_form) do
        create(
          :application_form,
          :with_degree,
          recruitment_cycle_year: 2025,
        )
      end

      it 'returns the degree review path' do
        expect(presenter.degrees_path).to eq(Rails.application.routes.url_helpers.candidate_interface_degree_review_path)
      end
    end
  end

  describe '#personal_details_completed?' do
    it 'returns true if personal details section is completed' do
      application_form = build(:application_form, personal_details_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_personal_details_completed
    end

    it 'returns false if personal details section is incomplete' do
      application_form = build(:application_form, personal_details_completed: false)
      presenter = described_class.new(application_form)
      expect(presenter).not_to be_personal_details_completed
    end
  end

  describe '#contact_details_completed?' do
    it 'returns true if contact details section is completed' do
      application_form = build(:application_form, contact_details_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_contact_details_completed
    end

    it 'returns false if contact details section is incomplete' do
      application_form = build(:application_form, contact_details_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_contact_details_completed
    end
  end

  describe '#contact_details_valid?' do
    subject(:presenter) { described_class.new(application_form) }

    context 'when contact details are valid' do
      let(:application_form) { build(:completed_application_form, contact_details_completed: true) }

      it 'returns true' do
        expect(presenter).to be_contact_details_valid
      end
    end

    context 'when contact details are invalid' do
      let(:application_form) { build(:completed_application_form, phone_number: '') }

      it 'returns false' do
        expect(presenter).not_to be_contact_details_valid
      end
    end
  end

  describe '#maths_gcse_completed?' do
    it 'returns true if maths gcse section is completed' do
      application_form = build(:application_form, maths_gcse_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_maths_gcse_completed
    end

    it 'returns false if maths gcse section is incomplete' do
      application_form = build(:application_form, maths_gcse_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_maths_gcse_completed
    end
  end

  describe '#english_gcse_completed?' do
    it 'returns true if english gcse section is completed' do
      application_form = build(:application_form, english_gcse_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_english_gcse_completed
    end

    it 'returns false if english gcse section is incomplete' do
      application_form = build(:application_form, english_gcse_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_english_gcse_completed
    end
  end

  describe '#science_gcse_completed?' do
    it 'returns true if science gcse section is completed' do
      application_form = build(:application_form, science_gcse_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_science_gcse_completed
    end

    it 'returns false if science gcse section is incomplete' do
      application_form = build(:application_form, science_gcse_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_science_gcse_completed
    end
  end

  describe '#degrees_completed?' do
    it 'returns true if degrees section is completed' do
      application_form = build(:application_form, degrees_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_degrees_completed
    end

    it 'returns false if degrees section is incomplete' do
      application_form = build(:application_form, degrees_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_degrees_completed
    end
  end

  describe '#other_qualifications_completed?' do
    it 'returns true if other qualifications section is completed and there are no incompleted qualifications' do
      application_form = build(:application_form, other_qualifications_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_other_qualifications_completed
    end

    it 'returns false if other qualifications section is incomplete' do
      application_form = build(:application_form, other_qualifications_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_other_qualifications_completed
    end

    it 'returns false if other qualifications is completed but there is an incomplete qualification' do
      application_form = build(:application_form, other_qualifications_completed: true)
      create(:other_qualification,
             subject: nil,
             grade: nil,
             application_form:)

      presenter = described_class.new(application_form)

      expect(presenter).not_to be_other_qualifications_completed
    end
  end

  describe '#other_qualifications_added?' do
    it 'returns true if other qualifications have been added' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(level: 'other')
      end
      presenter = described_class.new(application_form)

      expect(presenter.other_qualifications_added?).to be(true)
    end

    it 'returns false if no other qualifications are added' do
      application_form = create(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter.other_qualifications_added?).to be(false)
    end
  end

  describe '#training_with_a_disability_completed?' do
    it 'returns true if training with a disability section is completed' do
      application_form = build(:completed_application_form)
      presenter = described_class.new(application_form)

      expect(presenter).to be_training_with_a_disability_completed
    end

    it 'returns false if maths training with a disability section is incomplete' do
      application_form = build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_training_with_a_disability_completed
    end
  end

  describe '#training_with_a_disability_valid?' do
    it 'returns true if training with a disability section is completed' do
      application_form = build(:completed_application_form)
      presenter = described_class.new(application_form)

      expect(presenter).to be_training_with_a_disability_valid
    end

    it 'returns true if training with a disability section is incomplete' do
      application_form = build(:completed_application_form, disclose_disability: '')
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_training_with_a_disability_valid
    end
  end

  describe '#volunteering_completed?' do
    it 'returns true if volunteering section is completed' do
      application_form = build(:application_form, volunteering_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_volunteering_completed
    end

    it 'returns false if volunteering section is incomplete' do
      application_form = build(:application_form, volunteering_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_volunteering_completed
    end
  end

  describe '#volunteering_added?' do
    it 'returns true if volunteering have been added' do
      application_form = create(:completed_application_form, volunteering_experiences_count: 1)
      presenter = described_class.new(application_form)

      expect(presenter).to be_volunteering_added
    end

    it 'returns false if no volunteering are added' do
      application_form = build(:completed_application_form, volunteering_experiences_count: 0)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_volunteering_added
    end
  end

  describe '#references_completed?' do
    it 'returns true if application form references_completed is true' do
      application_form = build(:application_form, references_completed: true)
      presenter = described_class.new(application_form)
      expect(presenter).to be_references_completed
    end

    it 'returns false if application form references_completed is false' do
      application_form = build(:application_form, references_completed: false)
      presenter = described_class.new(application_form)
      expect(presenter).not_to be_references_completed
    end
  end

  describe '#safeguarding_completed?' do
    it 'returns true if the safeguarding section is completed' do
      application_form = build(:application_form, safeguarding_issues_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_safeguarding_completed
    end

    it 'returns false if safeguarding section is incomplete' do
      application_form = build(:application_form, safeguarding_issues_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_safeguarding_completed
    end
  end

  describe '#safeguarding_valid?' do
    it 'returns true if safeguarding section is completed' do
      application_form = build(:completed_application_form, :with_safeguarding_issues_disclosed)
      presenter = described_class.new(application_form)

      expect(presenter).to be_safeguarding_valid
    end

    it 'returns true if safeguarding section is incomplete' do
      application_form = build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_safeguarding_valid
    end
  end

  describe '#work_experience_path' do
    let(:application_form) do
      create(
        :completed_application_form,
        work_experiences_count:,
        work_history_explanation:,
        work_history_status:,
      )
    end
    let(:presenter) { described_class.new(application_form) }
    let(:work_experiences_count) { 0 }
    let(:work_history_explanation) { nil }
    let(:work_history_status) { nil }

    subject(:work_experience_path) { presenter.work_experience_path }

    context 'without work experience' do
      it 'returns the length path' do
        expect(work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_path,
        )
      end
    end

    context 'with work experience' do
      let(:work_experiences_count) { 1 }

      it 'returns the review path' do
        expect(work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_review_path,
        )
      end
    end

    context 'with work history explanation' do
      let(:work_history_explanation) { 'Took time off' }

      it 'returns the review path' do
        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_review_path,
        )
      end
    end

    context 'with work history status as full time education' do
      let(:work_history_status) { 'full_time_education' }

      it 'returns the review path' do
        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_review_path,
        )
      end
    end
  end

  describe '#volunteering_path' do
    it 'returns the experience path if volunteering experience is not set' do
      application_form = build(:completed_application_form, volunteering_completed: false, volunteering_experience: nil)
      presenter = described_class.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_volunteering_experience_path,
      )
    end

    it 'returns the review path if candidate has no volunteering experience' do
      application_form = build(:completed_application_form, volunteering_completed: false, volunteering_experience: false)
      presenter = described_class.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_review_volunteering_path,
      )
    end

    it 'returns the review path if candidate has volunteering experience' do
      application_form = create(:completed_application_form, volunteering_completed: false, volunteering_experience: true, volunteering_experiences_count: 1)

      presenter = described_class.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_review_volunteering_path,
      )
    end

    it 'returns the review path if volunteering section is completed' do
      application_form = build(:completed_application_form, volunteering_completed: true, volunteering_experiences_count: 1)

      presenter = described_class.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_review_volunteering_path,
      )
    end
  end

  describe '#application_choice_errors' do
    let(:application_choice_1) do
      instance_double(
        ApplicationChoice,
        id: 888,
        course_not_available?: false,
        course_full?: false,
        site_full?: false,
        study_mode_full?: false,
        course_application_status_closed?: false,
        site_invalid?: false,
      )
    end

    let(:application_choice_2) do
      instance_double(
        ApplicationChoice,
        id: 999,
        course_not_available?: false,
        course_full?: false,
        site_full?: false,
        study_mode_full?: false,
        course_application_status_closed?: false,
        site_invalid?: false,
      )
    end

    let(:application_form) do
      build_stubbed(:completed_application_form)
    end

    let(:presenter) { described_class.new(application_form) }

    before do
      allow(application_form).to receive(:application_choices).and_return([
        application_choice_1,
        application_choice_2,
      ])
    end

    it 'is empty with valid application choices' do
      expect(presenter.application_choice_errors).to be_empty
    end

    context 'a course is not available' do
      before do
        allow(application_choice_2).to receive_messages(course_not_available?: true, course_not_available_error: 'course_not_available')
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[course_not_available]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a course is closed on Apply' do
      before do
        allow(application_choice_2).to receive_messages(course_application_status_closed?: true, course_application_status_closed: 'course_closed_by_provider')
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[course_closed_by_provider]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a course is full' do
      before do
        allow(application_choice_2).to receive_messages(course_full?: true, course_full_error: 'course_full')
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[course_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a chosen site is full' do
      before do
        allow(application_choice_2).to receive_messages(site_full?: true, site_full_error: 'site_full')
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[site_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a course option has been removed by the provider' do
      before do
        allow(application_choice_2).to receive_messages(site_invalid?: true, site_invalid_error: 'site_invalid')
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[site_invalid]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a chosen study-mode is full' do
      before do
        allow(application_choice_2).to receive_messages(study_mode_full?: true, study_mode_full_error: 'study_mode_full')
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[study_mode_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'all application choices have errors' do
      before do
        allow(application_choice_1).to receive_messages(course_not_available?: true, course_not_available_error: 'course_not_available')
        allow(application_choice_2).to receive_messages(site_full?: true, site_full_error: 'site_full')
      end

      it 'returns errors for all choices' do
        errors = presenter.application_choice_errors
        expect(errors.map(&:message).zip(errors.map(&:anchor))).to contain_exactly(
          ['course_not_available', '#course-choice-888'],
          ['site_full', '#course-choice-999'],
        )
      end
    end
  end

  describe '#reference_section_errors' do
    it 'returns an error if a references_completed application form has an invalid number of selected references' do
      application_form = instance_double(
        ApplicationForm,
        references_completed?: true,
        complete_references_information?: false,
      )

      presenter = described_class.new(application_form)

      expect(presenter.reference_section_errors.count).to eq(1)
      error = presenter.reference_section_errors.first

      expect(error.class.name).to eq('CandidateInterface::ApplicationFormPresenter::ErrorMessage')
      expect(error.message).to eq('You need to have at least 2 references before submitting your application')
      expect(error.anchor).to eq('#references')
    end

    it 'returns an empty array if a references_completed application form has the required number of reference selections' do
      application_form = instance_double(
        ApplicationForm,
        references_completed?: true,
        complete_references_information?: true,
      )

      presenter = described_class.new(application_form)

      expect(presenter.reference_section_errors).to eq []
    end

    it 'returns an empty array if the application form is not references_completed' do
      application_form = instance_double(ApplicationForm, references_completed?: false)

      presenter = described_class.new(application_form)

      expect(presenter.reference_section_errors).to eq []
    end
  end

  describe '#becoming_a_teacher_completed?' do
    it 'returns true if the becoming a teacher section is completed' do
      application_form = build(:application_form, becoming_a_teacher_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_becoming_a_teacher_completed
    end

    it 'returns false if the becoming a teacher section is incomplete' do
      application_form = build(:application_form, becoming_a_teacher_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_becoming_a_teacher_completed
    end
  end

  describe '#interview_preferences_completed?' do
    it 'returns true if the interview preferences section is completed' do
      application_form = build(:application_form, interview_preferences_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_interview_preferences_completed
    end

    it 'returns false if the interview preferences section is incomplete' do
      application_form = build(:application_form, interview_preferences_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_interview_preferences_completed
    end
  end

  describe '#interview_preferences_valid?' do
    it 'returns true if the interview preference section is valid' do
      application_form = build(:completed_application_form, interview_preferences_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).to be_interview_preferences_valid
    end

    it 'returns false if the interview preferences section is invalid' do
      application_form = build(:application_form, interview_preferences_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_interview_preferences_valid
    end
  end

  describe '#no_incomplete_qualifications?' do
    it 'returns true if there are no incomplete qualifications' do
      application_form = create(:application_form)
      create(:other_qualification, application_form:)
      presenter = described_class.new(application_form)

      expect(presenter).to be_no_incomplete_qualifications
    end

    it 'allows optional grades for Other UK qualifications to be empty' do
      application_form = create(:application_form)
      create(:other_qualification, application_form:, grade: nil)
      presenter = described_class.new(application_form)

      expect(presenter).to be_no_incomplete_qualifications
    end

    it 'returns false if there is an incomplete qualification' do
      application_form = create(:application_form)
      create(:other_qualification, application_form:, award_year: nil)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_no_incomplete_qualifications
    end
  end

  describe '#previous_application_choices_unsuccessful?' do
    subject(:presenter) { described_class.new(application_form) }

    let(:application_form) do
      create(:application_form, previous_application_form_id: previous_application_form.id)
    end
    let(:previous_application_form) { create(:application_form) }

    context 'when one of the previous applications is rejected' do
      it 'returns true' do
        create(:application_choice, :rejected, application_form: previous_application_form)
        expect(presenter.previous_application_choices_unsuccessful?).to be true
      end
    end

    context 'when one of the previous applications is offer withdrawn' do
      it 'returns true' do
        create(:application_choice, :offer_withdrawn, application_form: previous_application_form)
        expect(presenter.previous_application_choices_unsuccessful?).to be true
      end
    end

    context 'when previous applications are not rejected' do
      it 'returns false' do
        create(:application_choice, :offered, application_form: previous_application_form)
        expect(presenter.previous_application_choices_unsuccessful?).to be false
      end
    end
  end

  describe '#can_submit_more_applications?' do
    context 'completed form, without choices, before the deadline', time: mid_cycle do
      it 'returns true' do
        application_form = create(:application_form, :completed, application_choices: [])
        presenter = described_class.new(application_form)

        expect(presenter.can_submit_more_applications?).to be true
      end
    end

    context 'form is not complete', time: mid_cycle do
      it 'returns false' do
        application_form = create(:application_form)
        presenter = described_class.new(application_form)

        expect(presenter.can_submit_more_applications?).to be false
      end
    end

    context 'the maximum number of choices has been met', time: mid_cycle do
      it 'returns false' do
        application_form = create(:application_form, :completed, submitted_application_choices_count: 4)
        presenter = described_class.new(application_form)

        expect(presenter.can_submit_more_applications?).to be false
      end
    end

    context 'the apply deadline has passed for this form', time: after_apply_deadline do
      it 'returns false' do
        application_form = create(:application_form, :completed, application_choices: [])
        presenter = described_class.new(application_form)

        expect(presenter.can_submit_more_applications?).to be false
      end
    end
  end

  describe '#path_to_previous_teacher_training' do
    context 'when path_to_previous_teacher_training is reviewable' do
      it 'returns the review path' do
        application_form = create(:application_form)
        create(
          :previous_teacher_training,
          :published,
          application_form:,
        )
        presenter = described_class.new(application_form)

        expect(presenter.path_to_previous_teacher_training).to eq(
          candidate_interface_previous_teacher_trainings_path,
        )
      end
    end

    context 'when path_to_previous_teacher_training is not reviewable' do
      it 'returns the start path' do
        application_form = create(:application_form)
        create(
          :previous_teacher_training,
          application_form:,
          started_at: nil,
        )
        presenter = described_class.new(application_form)

        expect(presenter.path_to_previous_teacher_training).to eq(
          start_candidate_interface_previous_teacher_trainings_path,
        )
      end
    end
  end
end
