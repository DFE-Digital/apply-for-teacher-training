require 'rails_helper'

RSpec.describe UCASMatchedApplication do
  let(:course) { create(:course, recruitment_cycle_year: 2020) }
  let(:candidate) { create(:candidate) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_choice) { create(:application_choice, course_option: course_option) }
  let(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
  let(:apply_again_application_form) { create(:application_form, candidate_id: candidate.id) }
  let(:recruitment_cycle_year) { 2020 }
  let(:candidate1) { create(:candidate) }
  let(:application_choice1) { create(:application_choice, :with_accepted_offer, course_option: course_option) }
  let(:application_form1) { create(:completed_application_form, candidate_id: candidate1.id, application_choices: [application_choice1]) }
  let(:candidate2) { create(:candidate) }
  let(:application_choice2) { create(:application_choice, :with_rejection, course_option: course_option) }
  let(:application_form2) { create(:completed_application_form, candidate_id: candidate2.id, application_choices: [application_choice2]) }

  before do
    apply_again_application_form
    application_form
    application_form1
    application_form2
    create(:course, code: course.code, provider: course.provider, recruitment_cycle_year: 2021)
  end

  describe '#course' do
    it 'returns the course for the correct recruitment cycle' do
      ucas_matching_data =
        { 'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.course).to eq(course)
    end

    it 'returns the course details for a course which is not on Apply' do
      ucas_matching_data =
        { 'Scheme' => 'U',
          'Course code' => '123',
          'Course name' => 'Not on Apply',
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.course.code).to eq('123')
      expect(ucas_matching_application.course.name).to eq('Not on Apply')
      expect(ucas_matching_application.course.provider).to eq(course.provider)
    end

    it 'handles missing course data' do
      ucas_matching_data =
        { 'Scheme' => 'U',
          'Course code' => '',
          'Course name' => '',
          'Provider code' => 'T80',
          'Apply candidate ID' => candidate.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.course.code).to eq('Missing course code')
      expect(ucas_matching_application.course.name).to eq('Missing course name')
      expect(ucas_matching_application.course.provider).to eq(nil)
    end
  end

  describe '#status' do
    context 'when it is a DfE match' do
      it 'returns the applications status' do
        dfe_matching_data =
          { 'Scheme' => 'D',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(dfe_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end

    context 'when it is a UCAS match' do
      it 'returns the applications status' do
        ucas_matching_data =
          { 'Scheme' => 'U',
            'Offers' => '.',
            'Rejects' => '1',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.status).to eq('rejected')
        expect(ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map(&:to_s)).to include(ucas_matching_application.status)
      end
    end

    context 'when it is a match on both systems' do
      it 'returns the applications status on apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s,
            'Offers' => '.',
            'Rejects' => '1',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end
  end

  describe '#application_in_progress_on_ucas?' do
    it 'returns true if application is not in an unsucesfull state on UCAS' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
          'Offers' => '1',
          'Rejects' => '.',
          'Withdrawns' => '.',
          'Applications' => '.',
          'Unconditional firm' => '1',
          'Applicant withdrawn entirely from scheme' => '.',
          'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
          'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
          'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(true)
    end

    it 'returns false if application is in unsucesfull state on UCAS' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate1.id.to_s,
          'Offers' => '.',
          'Rejects' => '.',
          'Withdrawns' => '1',
          'Applications' => '.',
          'Unconditional firm' => '.',
          'Applicant withdrawn entirely from scheme' => '.',
          'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
          'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
          'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(false)
    end

    it 'returns false the application is DfE scheme' do
      ucas_matching_data = { 'Scheme' => 'D' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(false)
    end

    it 'returns false the provider is not on apply' do
      ucas_matching_data = { 'Scheme' => 'U', 'Provider code' => 'WELSH PROVIDER CODE' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(false)
    end
  end

  describe '#application_in_progress_on_apply?' do
    it 'returns true if application is not in an unsucesfull state on Apply' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate1.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_apply?).to eq(true)
    end

    it 'returns false if application is in unsucesfull state on Apply' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate2.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
    end

    it 'returns false the application is UCAS scheme' do
      ucas_matching_data = { 'Scheme' => 'U' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
    end
  end

  describe '#application_accepted_on_ucas?' do
    it 'returns true if application is in recruited state on UCAS' do
      ucas_matching_data =
        { 'Scheme' => 'U',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
          'Offers' => '1',
          'Unconditional firm' => '1' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_accepted_on_ucas?).to eq(true)
    end

    it 'returns true if application is in pending_conditions state on UCAS' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
          'Offers' => '1',
          'Conditional firm' => '1' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_accepted_on_ucas?).to eq(true)
    end

    it 'returns false if application is in unsucesfull state on UCAS' do
      ucas_matching_data =
        { 'Scheme' => 'U',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate1.id.to_s,
          'Withdrawns' => '1' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_accepted_on_ucas?).to eq(false)
    end

    it 'returns false when the application is DfE scheme' do
      ucas_matching_data = { 'Scheme' => 'D' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_accepted_on_ucas?).to eq(false)
    end

    it 'returns false when the provider is not on Apply' do
      ucas_matching_data = { 'Scheme' => 'U', 'Provider code' => 'WELSH PROVIDER CODE' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_accepted_on_ucas?).to eq(false)
    end
  end

  describe '#application_accepted_on_apply?' do
    it 'returns true if application is accepted on Apply' do
      ucas_matching_data =
        { 'Scheme' => 'D',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate1.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_apply?).to eq(true)
    end

    it 'returns false if application is in unsucesfull state on Apply' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate2.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
    end

    it 'returns false if the application is in UCAS scheme' do
      ucas_matching_data = { 'Scheme' => 'U' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
    end
  end

  describe '#application_choice' do
    it 'returns the application_choice related with the candidate and course option' do
      ucas_matching_data =
        { 'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate2.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_choice).to eq(application_choice2)
    end
  end

  describe '#application_withdrawn_on_ucas?' do
    it 'returns true if application has been withdrawn on UCAS' do
      ucas_matching_data = { 'Withdrawns' => '1' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_withdrawn_on_ucas?).to eq(true)
    end

    it 'returns false if application has not been withdrawn on UCAS' do
      ucas_matching_data = { 'Withdrawns' => '' }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_withdrawn_on_ucas?).to eq(false)
    end
  end

  describe '#application_withdrawn_on_apply?' do
    context 'when the application_choice status is set to withdrawn' do
      let(:application_choice) { create(:application_choice, course_option: course_option, status: 'withdrawn') }

      it 'retuns true' do
        dfe_matching_data =
          { 'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(dfe_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_withdrawn_on_apply?).to eq(true)
      end
    end

    context 'when the application_choice status is not set to withdrawn' do
      let(:application_choice) { create(:application_choice, course_option: course_option, status: (ApplicationStateChange.valid_states - [:withdrawn]).sample) }

      it 'retuns false' do
        dfe_matching_data =
          { 'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(dfe_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_withdrawn_on_apply?).to eq(false)
      end
    end
  end
end
