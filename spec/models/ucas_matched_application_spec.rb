require 'rails_helper'

RSpec.describe UCASMatchedApplication do
  let(:recruitment_cycle_year) { 2020 }
  let(:candidate) { build_stubbed(:candidate) }
  let(:provider) { build_stubbed(:provider) }
  let(:course) { build_stubbed(:course, recruitment_cycle_year: recruitment_cycle_year, provider: provider) }
  let(:course_option) { build_stubbed(:course_option, course: course) }

  describe '#course' do
    let(:course) { create(:course, recruitment_cycle_year: 2020) }
    let(:ucas_matching_data) do
      {
        'Course code' => course.code.to_s,
        'Provider code' => course.provider.code.to_s,
        'Apply candidate ID' => candidate.id.to_s,
      }
    end

    it 'returns the course for the correct recruitment cycle' do
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, course.recruitment_cycle_year)

      expect(ucas_matching_application.course).to eq(course)
    end

    context 'when a course is not on Apply' do
      let(:provider) { create(:provider) }
      let(:ucas_matching_data) do
        {
          'Course code' => '123',
          'Course name' => 'Not on Apply',
          'Provider code' => course.provider.code.to_s,
        }
      end

      it 'returns the correct course details' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, course.recruitment_cycle_year)

        expect(ucas_matching_application.course.code).to eq('123')
        expect(ucas_matching_application.course.name).to eq('Not on Apply')
        expect(ucas_matching_application.course.provider).to eq(course.provider)
      end

      context 'when no course data is provided' do
        let(:ucas_matching_data) do
          {
            'Course code' => '',
            'Course name' => '',
            'Provider code' => 'T80',
          }
        end

        it 'returns a missing data string' do
          ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.course.code).to eq('Missing course code')
          expect(ucas_matching_application.course.name).to eq('Missing course name')
          expect(ucas_matching_application.course.provider).to eq(nil)
        end
      end
    end
  end

  describe '#status' do
    context 'when in the DfE scheme' do
      let(:application_choice) { build_stubbed(:application_choice, course_option: course_option) }
      let(:apply_matching_data) do
        {
          'Scheme' => 'D',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
        }
      end

      it 'returns the application status' do
        ucas_matching_application = UCASMatchedApplication.new(apply_matching_data, recruitment_cycle_year)
        allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end

    context 'when in the UCAS scheme' do
      let(:ucas_matching_data) do
        {
          'Scheme' => 'U',
          'Offers' => '.',
          'Rejects' => '1',
          'Withdrawns' => '.',
          'Applications' => '.',
          'Unconditional firm' => '.',
        }
      end

      it 'returns the ucas status' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.status).to eq('rejected')
        expect(ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map(&:to_s)).to include(ucas_matching_application.status)
      end
    end

    context 'when in both schemes' do
      let(:application_choice) { build_stubbed(:application_choice, course_option: course_option) }
      let(:ucas_matching_data) do
        {
          'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
        }
      end

      it 'returns the application status' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)
        allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end
  end

  describe '#application_in_progress_on_ucas?' do
    context 'when there is a provider' do
      let(:provider) { create(:provider) }
      let(:ucas_matching_data) do
        {
          'Scheme' => 'B',
          'Provider code' => course.provider.code.to_s,
          'Offers' => '',
          'Rejects' => '.',
          'Withdrawns' => '.',
          'Applications' => '.',
          'Unconditional firm' => '',
        }
      end

      context 'when the application is not in an unsuccessful state on UCAS' do
        let(:matching_data) { ucas_matching_data }

        it 'returns true' do
          ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(true)
        end
      end

      context 'when the application is in an unsuccessful state on UCAS' do
        let(:matching_data) { ucas_matching_data.merge('Withdrawns' => '1') }

        it 'returns false' do
          ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(false)
        end
      end

      context 'when the application is in the DfE scheme' do
        let(:ucas_matching_data) { { 'Scheme' => 'D' } }

        it 'returns false' do
          ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(false)
        end
      end
    end

    context 'when the provider is not on Apply' do
      let(:ucas_matching_data) { { 'Scheme' => 'U', 'Provider code' => 'WELSH PROVIDER CODE' } }

      it 'returns false' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_in_progress_on_ucas?).to eq(false)
      end
    end
  end

  describe '#application_in_progress_on_apply?' do
    context 'when the application is on Apply' do
      let(:ucas_matching_data) do
        {
          'Scheme' => 'B',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
        }
      end

      context 'when successful' do
        let(:application_choice) { build_stubbed(:application_choice, :with_accepted_offer) }

        it 'returns true' do
          ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)
          allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

          expect(ucas_matching_application.application_in_progress_on_apply?).to eq(true)
        end
      end

      context 'when unsuccessful' do
        let(:application_choice) { build_stubbed(:application_choice, :with_rejection) }

        it 'returns false' do
          ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)
          allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

          expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
        end
      end
    end

    context 'when the application is on UCAS' do
      let(:ucas_matching_data) { { 'Scheme' => 'U' } }

      it 'returns false' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
      end
    end
  end

  describe '#application_accepted_on_ucas?' do
    before do
      allow(Provider).to receive(:exists?).and_return(true)
    end

    context 'when the application is on UCAS' do
      let(:ucas_matching_data) do
        {
          'Scheme' => 'U',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
        }
      end

      context 'when in a recruited state' do
        let(:matching_data) { ucas_matching_data.merge('Offers' => '1', 'Unconditional firm' => '1') }

        it 'returns true' do
          ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.application_accepted_on_ucas?).to eq(true)
        end
      end

      context 'when in a pending_conditions state' do
        let(:matching_data) { ucas_matching_data.merge('Offers' => '1', 'Conditional firm' => '1') }

        it 'returns true' do
          ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.application_accepted_on_ucas?).to eq(true)
        end
      end

      context 'when in an unsuccesful state' do
        let(:matching_data) { ucas_matching_data.merge('Withdrawns' => '1') }

        it 'returns false' do
          ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

          expect(ucas_matching_application.application_accepted_on_ucas?).to eq(false)
        end
      end
    end

    context 'when the application is in the DfE scheme' do
      let(:ucas_matching_data) { { 'Scheme' => 'D' } }

      it 'returns false' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_accepted_on_ucas?).to eq(false)
      end
    end

    context 'when the provider is not on Apply' do
      let(:ucas_matching_data) { { 'Scheme' => 'U', 'Provider code' => 'WELSH PROVIDER CODE' } }

      it 'returns false' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_accepted_on_ucas?).to eq(false)
      end
    end
  end

  describe '#application_accepted_on_apply?' do
    context 'when on Apply' do
      let(:matching_data) do
        {
          'Scheme' => 'D',
          'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s,
        }
      end

      context 'when the application is accepted' do
        let(:application_choice) { build_stubbed(:application_choice, :pending_conditions) }

        it 'returns true' do
          ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)
          allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

          expect(ucas_matching_application.application_accepted_on_apply?).to eq(true)
        end
      end

      context 'when the application is not accepted' do
        let(:application_choice) { build_stubbed(:application_choice, :declined) }

        it 'returns false' do
          ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)
          allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

          expect(ucas_matching_application.application_accepted_on_apply?).to eq(false)
        end
      end
    end

    context 'when on UCAS scheme' do
      let(:ucas_matching_data) { { 'Scheme' => 'U' } }

      it 'returns false' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_in_progress_on_apply?).to eq(false)
      end
    end
  end

  describe '#application_choice' do
    let!(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
    let(:application_choice) { build(:application_choice, course_option: course_option) }
    let(:candidate) { create(:candidate) }
    let(:course) { build(:course, recruitment_cycle_year: recruitment_cycle_year) }
    let(:course_option) { build(:course_option, course: course) }
    let(:ucas_matching_data) do
      {
        'Course code' => course.code.to_s,
        'Provider code' => course.provider.code.to_s,
        'Apply candidate ID' => candidate.id.to_s,
      }
    end

    it 'returns the application_choice related with the candidate and course option' do
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

      expect(ucas_matching_application.application_choice).to eq(application_choice)
    end
  end

  describe '#application_withdrawn_on_ucas?' do
    context 'when the application has been withdrawn on UCAS' do
      let(:ucas_matching_data) { { 'Withdrawns' => '1' } }

      it 'returns true' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_withdrawn_on_ucas?).to eq(true)
      end
    end

    context 'when the application has not been withdrawn on UCAS' do
      let(:ucas_matching_data) { { 'Withdrawns' => '' } }

      it 'returns false' do
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data, recruitment_cycle_year)

        expect(ucas_matching_application.application_withdrawn_on_ucas?).to eq(false)
      end
    end
  end

  describe '#application_withdrawn_on_apply?' do
    let(:matching_data) do
      {
        'Course code' => course.code.to_s,
        'Provider code' => course.provider.code.to_s,
        'Apply candidate ID' => candidate.id.to_s,
      }
    end

    context 'when the application has been withdrawn on Apply' do
      let(:application_choice) { build_stubbed(:application_choice, course_option: course_option, status: 'withdrawn') }

      it 'retuns true' do
        ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)
        allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

        expect(ucas_matching_application.application_withdrawn_on_apply?).to eq(true)
      end
    end

    context 'when the application has not been withdrawn on Apply' do
      let(:application_choice) do
        build_stubbed(
          :application_choice,
          course_option: course_option,
          status: (ApplicationStateChange.valid_states - [:withdrawn]).sample,
        )
      end

      it 'retuns false' do
        ucas_matching_application = UCASMatchedApplication.new(matching_data, recruitment_cycle_year)
        allow(ucas_matching_application).to receive(:application_choice).and_return(application_choice)

        expect(ucas_matching_application.application_withdrawn_on_apply?).to eq(false)
      end
    end
  end
end
