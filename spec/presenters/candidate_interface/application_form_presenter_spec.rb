require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormPresenter do
  describe '#personal_details_completed?' do
    it 'returns true if personal details section is completed' do
      application_form = FactoryBot.build(:application_form, personal_details_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_personal_details_completed
    end

    it 'returns false if personal details section is incomplete' do
      application_form = FactoryBot.build(:application_form, personal_details_completed: false)
      presenter = described_class.new(application_form)
      expect(presenter).not_to be_personal_details_completed
    end
  end

  describe '#contact_details_completed?' do
    it 'returns true if contact details section is completed' do
      application_form = FactoryBot.build(:application_form, contact_details_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_contact_details_completed
    end

    it 'returns false if contact details section is incomplete' do
      application_form = FactoryBot.build(:application_form, contact_details_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_contact_details_completed
    end
  end

  describe '#contact_details_valid?' do
    it 'returns true if contact details section is completed' do
      application_form = FactoryBot.build(:completed_application_form, contact_details_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_contact_details_valid
    end

    it 'returns false if contact details section is invalid' do
      application_form = FactoryBot.build(:completed_application_form, phone_number: '')
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_contact_details_valid
    end
  end

  describe '#maths_gcse_completed?' do
    it 'returns true if maths gcse section is completed' do
      application_form = FactoryBot.build(:application_form, maths_gcse_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_maths_gcse_completed
    end

    it 'returns false if maths gcse section is incomplete' do
      application_form = FactoryBot.build(:application_form, maths_gcse_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_maths_gcse_completed
    end
  end

  describe '#maths_gcse_added?' do
    it 'returns true if maths gcse has been added' do
      application_form = FactoryBot.create(:application_form, :with_gcses)
      presenter = described_class.new(application_form)

      expect(presenter).to be_maths_gcse_added
    end

    it 'returns false if maths gcse has been not been added' do
      application_form = FactoryBot.build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_maths_gcse_added
    end
  end

  describe '#english_gcse_completed?' do
    it 'returns true if english gcse section is completed' do
      application_form = FactoryBot.build(:application_form, english_gcse_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_english_gcse_completed
    end

    it 'returns false if english gcse section is incomplete' do
      application_form = FactoryBot.build(:application_form, english_gcse_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_english_gcse_completed
    end
  end

  describe '#english_gcse_added?' do
    it 'returns true if english gcse has been added' do
      application_form = FactoryBot.create(:application_form, :with_gcses)
      presenter = described_class.new(application_form)

      expect(presenter).to be_english_gcse_added
    end

    it 'returns false if english gcse has been not been added' do
      application_form = FactoryBot.build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_english_gcse_added
    end
  end

  describe '#science_gcse_completed?' do
    it 'returns true if science gcse section is completed' do
      application_form = FactoryBot.build(:application_form, science_gcse_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_science_gcse_completed
    end

    it 'returns false if science gcse section is incomplete' do
      application_form = FactoryBot.build(:application_form, science_gcse_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_science_gcse_completed
    end
  end

  describe '#science_gcse_added?' do
    it 'returns true if science gcse has been added' do
      application_form = FactoryBot.create(:application_form, :with_gcses)
      presenter = described_class.new(application_form)

      expect(presenter).to be_science_gcse_added
    end

    it 'returns false if science gcse has been not been added' do
      application_form = FactoryBot.build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_science_gcse_added
    end
  end

  describe '#degrees_completed?' do
    it 'returns true if degrees section is completed' do
      application_form = FactoryBot.build(:application_form, degrees_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_degrees_completed
    end

    it 'returns false if degrees section is incomplete' do
      application_form = FactoryBot.build(:application_form, degrees_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_degrees_completed
    end
  end

  describe '#degrees_added?' do
    it 'returns true if degrees have been added' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'degree',
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'first',
          predicted_grade: false,
          start_year: '2005',
          award_year: '2008',
        )
      end
      presenter = described_class.new(application_form)

      expect(presenter).to be_degrees_added
    end

    it 'returns false if no degrees are added' do
      application_form = FactoryBot.create(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_degrees_added
    end
  end

  describe '#other_qualifications_completed?' do
    it 'returns true if other qualifications section is completed and there are no incompleted qualifications' do
      application_form = FactoryBot.build(:application_form, other_qualifications_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_other_qualifications_completed
    end

    it 'returns false if other qualifications section is incomplete' do
      application_form = FactoryBot.build(:application_form, other_qualifications_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_other_qualifications_completed
    end

    it 'returns false if other qualifications is completed but there is an incomplete qualification' do
      application_form = FactoryBot.build(:application_form, other_qualifications_completed: true)
      create(:other_qualification,
             subject: nil,
             grade: nil,
             application_form: application_form)

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

      expect(presenter.other_qualifications_added?).to eq(true)
    end

    it 'returns false if no other qualifications are added' do
      application_form = FactoryBot.create(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter.other_qualifications_added?).to eq(false)
    end
  end

  describe '#application_choices_added?' do
    it 'returns true if application choices are added' do
      application_form = create(:completed_application_form, application_choices_count: 1)
      presenter = described_class.new(application_form)

      expect(presenter).to be_application_choices_added
    end

    it 'returns false if no application choices are added' do
      application_form = FactoryBot.build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_application_choices_added
    end
  end

  describe '#training_with_a_disability_completed?' do
    it 'returns true if training with a disabilitty section is completed' do
      application_form = FactoryBot.build(:completed_application_form)
      presenter = described_class.new(application_form)

      expect(presenter).to be_training_with_a_disability_completed
    end

    it 'returns false if maths training with a disabilitty section is incomplete' do
      application_form = FactoryBot.build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_training_with_a_disability_completed
    end
  end

  describe '#training_with_a_disability_valid?' do
    it 'returns true if training with a disability section is completed' do
      application_form = FactoryBot.build(:completed_application_form)
      presenter = described_class.new(application_form)

      expect(presenter).to be_training_with_a_disability_valid
    end

    it 'returns true if training with a disability section is incomplete' do
      application_form = FactoryBot.build(:completed_application_form, disclose_disability: '')
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
      application_form = FactoryBot.build(:application_form, safeguarding_issues_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_safeguarding_completed
    end

    it 'returns false if safeguarding section is incomplete' do
      application_form = FactoryBot.build(:application_form, safeguarding_issues_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_safeguarding_completed
    end
  end

  describe '#safeguarding_valid?' do
    it 'returns true if safeguarding section is completed' do
      application_form = FactoryBot.build(:completed_application_form, :with_safeguarding_issues_disclosed)
      presenter = described_class.new(application_form)

      expect(presenter).to be_safeguarding_valid
    end

    it 'returns true if safeguarding section is incomplete' do
      application_form = FactoryBot.build(:application_form)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_safeguarding_valid
    end
  end

  describe '#work_experience_path' do
    context 'with the restructured_work_history flag off' do
      before do
        FeatureFlag.deactivate(:restructured_work_history)
      end

      it 'returns the length path if no work experience' do
        application_form = build(:completed_application_form, work_experiences_count: 0, work_history_explanation: '')
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_work_history_length_path,
        )
      end

      it 'returns the review path if work experience' do
        application_form = create(:completed_application_form, work_experiences_count: 1, work_history_explanation: '')
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_work_history_show_path,
        )
      end

      it 'returns the review path if not recently worked' do
        application_form = build_stubbed(:application_form, work_history_explanation: 'I was on a career break.')
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_work_history_show_path,
        )
      end
    end

    context 'with the restructured_work_history flag on' do
      before do
        FeatureFlag.activate(:restructured_work_history)
      end

      it 'returns the length path if no work experience and feature_restructured_work_history is "false"' do
        application_form = build(:completed_application_form, work_experiences_count: 0, work_history_explanation: '', feature_restructured_work_history: false)
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_work_history_length_path,
        )
      end

      it 'returns the review path if work experience and feature_restructured_work_history is "false"' do
        application_form = create(:completed_application_form, work_experiences_count: 1, work_history_explanation: '', feature_restructured_work_history: false)
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_work_history_show_path,
        )
      end

      it 'returns the review path if not recently worked and feature_restructured_work_history is "false"' do
        application_form = build_stubbed(:application_form, work_history_explanation: 'I was on a career break.', feature_restructured_work_history: false)
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_work_history_show_path,
        )
      end

      it 'returns the length path if no work experience' do
        application_form = build(:completed_application_form, work_experiences_count: 0, work_history_explanation: '')
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_path,
        )
      end

      it 'returns the review path if work experience' do
        application_form = create(:completed_application_form, work_experiences_count: 1, work_history_explanation: '')
        presenter = described_class.new(application_form)

        expect(presenter.work_experience_path).to eq(
          Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_review_path('return-to' => 'application-review'),
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
        course_closed_on_apply?: false,
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
        course_closed_on_apply?: false,
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
        allow(application_choice_2).to receive(:course_not_available?).and_return true
        allow(application_choice_2).to receive(:course_not_available_error).and_return 'course_not_available'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[course_not_available]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a course is closed on Apply' do
      before do
        allow(application_choice_2).to receive(:course_closed_on_apply?).and_return true
        allow(application_choice_2).to receive(:course_closed_on_apply_error).and_return 'course_not_available_on_apply'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[course_not_available_on_apply]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a course is full' do
      before do
        allow(application_choice_2).to receive(:course_full?).and_return true
        allow(application_choice_2).to receive(:course_full_error).and_return 'course_full'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[course_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a chosen site is full' do
      before do
        allow(application_choice_2).to receive(:site_full?).and_return true
        allow(application_choice_2).to receive(:site_full_error).and_return 'site_full'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[site_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a course option has been removed by the provider' do
      before do
        allow(application_choice_2).to receive(:site_invalid?).and_return true
        allow(application_choice_2).to receive(:site_invalid_error).and_return 'site_invalid'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[site_invalid]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'a chosen study-mode is full' do
      before do
        allow(application_choice_2).to receive(:study_mode_full?).and_return true
        allow(application_choice_2).to receive(:study_mode_full_error).and_return 'study_mode_full'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[study_mode_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'all application choices have errors' do
      before do
        allow(application_choice_1).to receive(:course_not_available?).and_return true
        allow(application_choice_1).to receive(:course_not_available_error).and_return 'course_not_available'
        allow(application_choice_2).to receive(:site_full?).and_return true
        allow(application_choice_2).to receive(:site_full_error).and_return 'site_full'
      end

      it 'returns errors for all choices' do
        errors = presenter.application_choice_errors
        expect(errors.map(&:message).zip(errors.map(&:anchor))).to match_array([
          ['course_not_available', '#course-choice-888'],
          ['site_full', '#course-choice-999'],
        ])
      end
    end
  end

  describe '#reference_section_errors' do
    it 'returns an error if a references_completed application form has an invalid number of selected references' do
      application_form = instance_double(
        ApplicationForm,
        references_completed?: true,
        selected_incorrect_number_of_references?: true,
      )
      presenter = described_class.new(application_form)

      expect(presenter.reference_section_errors).to eq(
        [OpenStruct.new(message: 'You need to have exactly 2 references selected before submitting your application', anchor: '#references')],
      )
    end

    it 'returns an empty array if a references_completed application form has the required number of reference selections' do
      application_form = instance_double(
        ApplicationForm,
        references_completed?: true,
        selected_incorrect_number_of_references?: false,
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
      application_form = FactoryBot.build(:application_form, becoming_a_teacher_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_becoming_a_teacher_completed
    end

    it 'returns false if the becoming a teacher section is incomplete' do
      application_form = FactoryBot.build(:application_form, becoming_a_teacher_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_becoming_a_teacher_completed
    end
  end

  describe '#becoming_a_teacher_valid?' do
    it 'returns true if the becoming a teacher section is valid' do
      application_form = FactoryBot.build(:completed_application_form, becoming_a_teacher_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).to be_becoming_a_teacher_valid
    end

    it 'returns false if the becoming a teacher section is invalid' do
      application_form = FactoryBot.build(:application_form, becoming_a_teacher_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_becoming_a_teacher_valid
    end
  end

  describe '#subject_knowledge_completed?' do
    it 'returns true if the interview prefrences section is completed' do
      application_form = FactoryBot.build(:application_form, subject_knowledge_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_subject_knowledge_completed
    end

    it 'returns false if the subject knowledge section is incomplete' do
      application_form = FactoryBot.build(:application_form, subject_knowledge_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_subject_knowledge_completed
    end
  end

  describe '#subject_knowledge_valid?' do
    it 'returns true if the subject knowledge section is valid' do
      application_form = FactoryBot.build(:completed_application_form, subject_knowledge_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).to be_subject_knowledge_valid
    end

    it 'returns false if the subject knowledge section is invalid' do
      application_form = FactoryBot.build(:application_form, subject_knowledge_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_subject_knowledge_valid
    end
  end

  describe '#interview_preferences_completed?' do
    it 'returns true if the interview preferences section is completed' do
      application_form = FactoryBot.build(:application_form, interview_preferences_completed: true)
      presenter = described_class.new(application_form)

      expect(presenter).to be_interview_preferences_completed
    end

    it 'returns false if the interview preferences section is incomplete' do
      application_form = FactoryBot.build(:application_form, interview_preferences_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_interview_preferences_completed
    end
  end

  describe '#interview_preferences_valid?' do
    it 'returns true if the intervew preference section is valid' do
      application_form = FactoryBot.build(:completed_application_form, interview_preferences_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).to be_interview_preferences_valid
    end

    it 'returns false if the interview preferences section is invalid' do
      application_form = FactoryBot.build(:application_form, interview_preferences_completed: false)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_interview_preferences_valid
    end
  end

  describe '#no_incomplete_qualifications?' do
    it 'returns true if there are no incomplete qualifications' do
      application_form = create(:application_form)
      create(:other_qualification, application_form: application_form)
      presenter = described_class.new(application_form)

      expect(presenter).to be_no_incomplete_qualifications
    end

    it 'allows optional grades for Other UK qualifications to be empty' do
      application_form = create(:application_form)
      create(:other_qualification, application_form: application_form, grade: nil)
      presenter = described_class.new(application_form)

      expect(presenter).to be_no_incomplete_qualifications
    end

    it 'returns false if there is an incomplete qualification' do
      application_form = create(:application_form)
      create(:other_qualification, application_form: application_form, award_year: nil)
      presenter = described_class.new(application_form)

      expect(presenter).not_to be_no_incomplete_qualifications
    end
  end

  describe '#references_link_text' do
    context 'no references present' do
      let(:application_form) { create(:application_form) }

      it 'returns the correct link text' do
        presenter = described_class.new(application_form)
        expect(presenter.references_link_text).to eq 'Add your references'
      end
    end

    context 'references present' do
      let(:application_form) { create(:application_form) }

      before { create(:reference, application_form: application_form) }

      it 'returns the correct link text' do
        presenter = described_class.new(application_form)
        expect(presenter.references_link_text).to eq 'Manage your references'
      end
    end
  end

  describe '#references_selection_path' do
    let(:application_form) { create(:application_form) }

    context 'no references have been selected' do
      it 'is the references start page' do
        create_list(:reference, 2, application_form: application_form)
        presenter = described_class.new(application_form)
        expect(presenter.references_selection_path).to eq Rails.application.routes.url_helpers.candidate_interface_select_references_path
      end
    end

    context '1 reference (of 2) has been selected' do
      it 'is the references start page' do
        create(:reference, application_form: application_form)
        create(:selected_reference, application_form: application_form)
        presenter = described_class.new(application_form)
        expect(presenter.references_selection_path).to eq Rails.application.routes.url_helpers.candidate_interface_select_references_path
      end
    end

    context '2 references have been selected' do
      it 'is the references start page' do
        create_list(:selected_reference, 2, application_form: application_form)
        presenter = described_class.new(application_form)
        expect(presenter.references_selection_path).to eq Rails.application.routes.url_helpers.candidate_interface_review_selected_references_path
      end
    end
  end
end
