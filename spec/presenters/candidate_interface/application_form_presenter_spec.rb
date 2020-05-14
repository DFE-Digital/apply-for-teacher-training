require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormPresenter do
  before do
    FeatureFlag.activate('mark_every_section_complete')
  end

  describe '#personal_details_completed?' do
    it 'returns true if personal details section is completed' do
      application_form = FactoryBot.build(:application_form, personal_details_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_personal_details_completed
    end

    it 'returns false if personal details section is incomplete' do
      application_form = FactoryBot.build(:application_form, personal_details_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)
      expect(presenter).not_to be_personal_details_completed
    end
  end

  describe '#contact_details_completed?' do
    it 'returns true if contact details section is completed' do
      application_form = FactoryBot.build(:application_form, contact_details_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_contact_details_completed
    end

    it 'returns false if contact details section is incomplete' do
      application_form = FactoryBot.build(:application_form, contact_details_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_contact_details_completed
    end
  end

  describe '#maths_gcse_completed?' do
    it 'returns true if maths gcse section is completed' do
      application_form = FactoryBot.build(:application_form, maths_gcse_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_maths_gcse_completed
    end

    it 'returns false if maths gcse section is incomplete' do
      application_form = FactoryBot.build(:application_form, maths_gcse_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_maths_gcse_completed
    end
  end

  describe '#english_gcse_completed?' do
    it 'returns true if english gcse section is completed' do
      application_form = FactoryBot.build(:application_form, english_gcse_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_english_gcse_completed
    end

    it 'returns false if english gcse section is incomplete' do
      application_form = FactoryBot.build(:application_form, english_gcse_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_english_gcse_completed
    end
  end

  describe '#science_gcse_completed?' do
    it 'returns true if science gcse section is completed' do
      application_form = FactoryBot.build(:application_form, science_gcse_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_science_gcse_completed
    end

    it 'returns false if science gcse section is incomplete' do
      application_form = FactoryBot.build(:application_form, science_gcse_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_science_gcse_completed
    end
  end

  describe '#degrees_completed?' do
    it 'returns true if degrees section is completed' do
      application_form = FactoryBot.build(:application_form, degrees_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_degrees_completed
    end

    it 'returns false if degrees section is incomplete' do
      application_form = FactoryBot.build(:application_form, degrees_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

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
          award_year: '2008',
        )
      end
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_degrees_added
    end

    it 'returns false if no degrees are added' do
      application_form = FactoryBot.create(:application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_degrees_added
    end
  end

  describe '#other_qualifications_completed?' do
    it 'returns true if other qualifications section is completed' do
      application_form = FactoryBot.build(:application_form, other_qualifications_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_other_qualifications_completed
    end

    it 'returns false if other qualifications section is incomplete' do
      application_form = FactoryBot.build(:application_form, other_qualifications_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_other_qualifications_completed
    end
  end

  describe '#other_qualifications_added?' do
    it 'returns true if other qualifications have been added' do
      application_form = create(:application_form) do |form|
        form.application_qualifications.create(level: 'other')
      end
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.other_qualifications_added?).to eq(true)
    end

    it 'returns false if no other qualifications are added' do
      application_form = FactoryBot.create(:application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.other_qualifications_added?).to eq(false)
    end
  end

  describe '#application_choices_added?' do
    it 'returns true if application choices are added' do
      application_form = FactoryBot.build(:completed_application_form, application_choices_count: 1)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_application_choices_added
    end

    it 'returns false if no application choices are added' do
      application_form = FactoryBot.build(:application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_application_choices_added
    end
  end

  describe '#training_with_a_disability_completed?' do
    let(:application_form) do
      FactoryBot.build(:completed_application_form)
    end
    let(:presenter) do
      CandidateInterface::ApplicationFormPresenter.new(application_form)
    end

    context 'when the candidate has not selected Yes or No to the disclosure question' do
      before do
        application_form.disclose_disability = nil
      end

      it 'returns false' do
        expect(presenter.training_with_a_disability_completed?).to eq(false)
      end
    end

    context 'when the candidate says Yes to disclosure but has not filled in the text field' do
      before do
        application_form.disclose_disability = true
        application_form.disability_disclosure = ''
      end

      it 'returns false' do
        expect(presenter.training_with_a_disability_completed?).to eq(false)
      end
    end

    context 'when the candidate says Yes to disclosure and has filled in the text field' do
      before do
        application_form.disclose_disability = true
        application_form.disability_disclosure = 'I have difficulty climbing stairs'
      end

      it 'returns true' do
        expect(presenter.training_with_a_disability_completed?).to eq(true)
      end
    end

    context 'when the candidate has selected No to the disclosure question' do
      before do
        application_form.disclose_disability = false
      end

      it 'returns true' do
        expect(presenter.training_with_a_disability_completed?).to eq(true)
      end
    end
  end

  describe '#volunteering_completed?' do
    it 'returns true if volunteering section is completed' do
      application_form = build(:application_form, volunteering_completed: true)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_volunteering_completed
    end

    it 'returns false if volunteering section is incomplete' do
      application_form = build(:application_form, volunteering_completed: false)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_volunteering_completed
    end
  end

  describe '#volunteering_added?' do
    it 'returns true if volunteering have been added' do
      application_form = build(:completed_application_form, volunteering_experiences_count: 1)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_volunteering_added
    end

    it 'returns false if no volunteering are added' do
      application_form = build(:completed_application_form, volunteering_experiences_count: 0)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_volunteering_added
    end
  end

  describe '#all_referees_provided_by_candidate?' do
    let(:application_form) do
      FactoryBot.create(:application_form)
    end
    let(:presenter) do
      CandidateInterface::ApplicationFormPresenter.new(application_form)
    end

    context 'when there are no referees' do
      before do
        application_form.application_references.delete_all
      end

      it 'returns false' do
        expect(presenter.all_referees_provided_by_candidate?).to eq(false)
      end
    end

    context 'when there is one referee' do
      before do
        create(:reference, application_form: application_form)
      end

      it 'returns false' do
        expect(presenter.all_referees_provided_by_candidate?).to eq(false)
      end
    end

    context 'when there are two referees' do
      before do
        create_list(:reference, 2, application_form: application_form)
      end

      it 'returns true' do
        expect(presenter.all_referees_provided_by_candidate?).to eq(true)
      end
    end

    context 'when there are 3 referees' do
      before do
        create_list(:reference, 3, application_form: application_form)
      end

      it 'returns true' do
        expect(presenter.all_referees_provided_by_candidate?).to eq(true)
      end
    end
  end

  describe '#safeguarding_completed?' do
    it 'returns false if safeguarding issues is not answered yet' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :not_answered_yet,
      )

      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.safeguarding_completed?).to eq(false)
    end

    it 'returns false if safeguarding issues question was not asked' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :never_asked,
      )

      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.safeguarding_completed?).to eq(false)
    end

    it 'returns true if safeguarding issues are declared' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: 'I have a criminal conviction',
        safeguarding_issues_status: :has_safeguarding_issues_to_declare,
      )

      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.safeguarding_completed?).to eq(true)
    end

    it 'returns true if safeguarding issues are denied' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: :no_safeguarding_issues_to_declare,
      )

      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.safeguarding_completed?).to eq(true)
    end
  end

  describe '#work_experience_path' do
    it 'returns the length path if no work experience' do
      application_form = build(:completed_application_form, work_experiences_count: 0, work_history_explanation: '')
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.work_experience_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_work_history_length_path,
      )
    end

    it 'returns the review path if work experience' do
      application_form = build(:completed_application_form, work_experiences_count: 1, work_history_explanation: '')
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.work_experience_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_work_history_show_path,
      )
    end

    it 'returns the review path if not recently worked' do
      application_form = build_stubbed(:application_form, work_history_explanation: 'I was on a career break.')
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.work_experience_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_work_history_show_path,
      )
    end
  end

  describe '#volunteering_path' do
    it 'returns the experience path if volunteering experience is not set' do
      application_form = build(:completed_application_form, volunteering_completed: false, volunteering_experience: nil, volunteering_experiences_count: 0)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_volunteering_experience_path,
      )
    end

    it 'returns the review path if no volunteering experience' do
      application_form = build(:completed_application_form, volunteering_completed: false, volunteering_experience: false, volunteering_experiences_count: 0)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_review_volunteering_path,
      )
    end

    it 'returns the review path if volunteering experience' do
      application_form = build(:completed_application_form, volunteering_completed: false, volunteering_experience: true, volunteering_experiences_count: 1)

      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter.volunteering_path).to eq(
        Rails.application.routes.url_helpers.candidate_interface_review_volunteering_path,
      )
    end

    it 'returns the review path if volunteering section is completed' do
      application_form = build(:completed_application_form, volunteering_completed: true, volunteering_experiences_count: 1)

      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

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
        chosen_site_full?: false,
        course_closed_on_apply?: false,
      )
    end

    let(:application_choice_2) do
      instance_double(
        ApplicationChoice,
        id: 999,
        course_not_available?: false,
        course_full?: false,
        chosen_site_full?: false,
        course_closed_on_apply?: false,
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
        allow(application_choice_2).to receive(:chosen_site_full?).and_return true
        allow(application_choice_2).to receive(:chosen_site_full_error).and_return 'site_full'
      end

      it 'returns the appropriate error' do
        expect(presenter.application_choice_errors.map(&:message)).to eq %w[site_full]
        expect(presenter.application_choice_errors.map(&:anchor)).to eq(['#course-choice-999'])
      end
    end

    context 'all application choices have errors' do
      before do
        allow(application_choice_1).to receive(:course_not_available?).and_return true
        allow(application_choice_1).to receive(:course_not_available_error).and_return 'course_not_available'
        allow(application_choice_2).to receive(:chosen_site_full?).and_return true
        allow(application_choice_2).to receive(:chosen_site_full_error).and_return 'site_full'
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
end
