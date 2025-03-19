require 'rails_helper'

RSpec.describe CandidateInterface::HesaCodeBackfill do
  describe '#call' do
    let(:current_year) { RecruitmentCycleTimetable.current_year }

    it 'populates an application form with hesa codes' do
      application_form = create(:application_form,
                                equality_and_diversity: {
                                  sex: 'female',
                                  ethnic_background: 'Caribbean',
                                  disabilities: %w[Blind Deaf],
                                })

      described_class.call(current_year)

      application_form.reload

      expect(application_form.equality_and_diversity).to eq(
        'hesa_sex' => '10',
        'hesa_disabilities' => %w[58 57],
        'hesa_ethnicity' => '121',
        'sex' => 'female',
        'ethnic_background' => 'Caribbean',
        'disabilities' => %w[Blind Deaf],
      )
    end

    context 'disability' do
      it "does not populate 'hesa_disabilites' if candidate 'prefers not to say'" do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    disabilities: ['Prefer not to say'],
                                  })

        described_class.call(current_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => ['Prefer not to say'],
          'hesa_disabilities' => nil,
          'hesa_ethnicity' => nil,
          'hesa_sex' => nil,
        )
      end

      it "does not populate 'hesa_disabilities' if disabilities is nil" do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    disabilities: nil,
                                  })

        described_class.call(current_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => nil,
          'hesa_disabilities' => nil,
          'hesa_ethnicity' => nil,
          'hesa_sex' => nil,
        )
      end

      it "populates 'hesa_disabilities' with hesa_code '96' for unknown disabilities" do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    disabilities: ['Acquired brain injury', 'Many unexplained illnesses'],
                                  })

        hesa_disability_code_other = '96'

        described_class.call(current_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => ['Acquired brain injury', 'Many unexplained illnesses'],
          'hesa_disabilities' => [hesa_disability_code_other],
          'hesa_ethnicity' => nil,
          'hesa_sex' => nil,
        )
      end
    end

    context 'ethnicity' do
      it "populates 'hesa_ethnicity' with hesa code '80' for an unknown ethnicity" do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    ethnic_background: 'Maori',
                                    disabilities: [],
                                  },
                                  recruitment_cycle_year: 2020)

        hesa_ethnicity_code_unknown = '90'

        described_class.call(2020)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_background' => 'Maori',
          'disabilities' => [],
          'hesa_disabilities' => nil,
          'hesa_ethnicity' => hesa_ethnicity_code_unknown,
          'hesa_sex' => nil,
        )
      end

      context 'when cycle year is 2020' do
        it "populates 'hesa_ethnicity' with hesa_code '98' when candidate 'prefers not to say'" do
          application_form = create(:application_form,
                                    equality_and_diversity: {
                                      ethnic_group: 'Prefer not to say',
                                      disabilities: [],
                                    },
                                    recruitment_cycle_year: 2020)

          hesa_ethnicity_code_refused = '98'

          described_class.call(2020)

          application_form.reload

          expect(application_form.equality_and_diversity).to eq(
            'ethnic_group' => 'Prefer not to say',
            'disabilities' => [],
            'hesa_disabilities' => nil,
            'hesa_ethnicity' => hesa_ethnicity_code_refused,
            'hesa_sex' => nil,
          )
        end
      end

      context 'when cycle year is 2021' do
        it "does not populate 'hesa_ethnicity' when candidate 'prefers not to say'" do
          application_form = create(:application_form,
                                    equality_and_diversity: {
                                      ethnic_group: 'Prefer not to say',
                                      disabilities: [],
                                    },
                                    recruitment_cycle_year: 2021)

          described_class.call(2021)

          application_form.reload

          expect(application_form.equality_and_diversity).to eq(
            'ethnic_group' => 'Prefer not to say',
            'disabilities' => [],
            'hesa_disabilities' => nil,
            'hesa_ethnicity' => '98',
            'hesa_sex' => nil,
          )
        end
      end
    end

    context 'sex' do
      it "populates 'hesa_sex' with hesa_code '12' when candidate is 'other'" do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    sex: 'other',
                                  })

        hesa_sex_code_other = '12'

        described_class.call(current_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'other',
          'hesa_sex' => hesa_sex_code_other,
          'hesa_disabilities' => nil,
          'hesa_ethnicity' => nil,
        )
      end
    end
  end
end
