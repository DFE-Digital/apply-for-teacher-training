require 'rails_helper'

RSpec.describe CandidateInterface::HesaCodeBackfill do
  describe '#call' do
    it 'populates an application form with hesa codes' do
      application_form = create(:application_form,
                                equality_and_diversity: {
                                  sex: 'female',
                                  ethnic_background: 'Caribbean',
                                  disabilities: %w[Blind Deaf],
                                })
      cycle_year = 2020

      described_class.call(cycle_year)

      application_form.reload

      expect(application_form.equality_and_diversity).to eq(
        'hesa_sex' => 2,
        'hesa_disabilities' => %w[58 57],
        'hesa_ethnicity' => 21,
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

        cycle_year = 2020

        described_class.call(cycle_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => ['Prefer not to say'],
          'hesa_disabilities' => nil,
          'hesa_ethnicity' => nil,
          'hesa_sex' => nil,
        )
      end

      it "populates 'hesa_disabilities' with hesa_code '96' for an unknown disability" do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    disabilities: ['Acquired brain injury'],
                                  })

        cycle_year = 2020

        described_class.call(cycle_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => ['Acquired brain injury'],
          'hesa_disabilities' => [described_class::HESA_DISABILITY_CODE_OTHER],
          'hesa_ethnicity' => nil,
          'hesa_sex' => nil,
        )
      end
    end

    context 'ethnicity' do
      it "populates 'hesa_ethnicity' with hesa code '80' for an unknown ethnicity " do
        application_form = create(:application_form,
                                  equality_and_diversity: {
                                    ethnic_background: 'Maori',
                                    disabilities: [],
                                  })

        cycle_year = 2020

        described_class.call(cycle_year)

        application_form.reload

        expect(application_form.equality_and_diversity).to eq(
          'ethnic_background' => 'Maori',
          'disabilities' => [],
          'hesa_disabilities' => nil,
          'hesa_ethnicity' => described_class::HESA_ETHNICITY_CODE_UNKNOWN,
          'hesa_sex' => nil,
        )
      end

      context 'when cycle year is 2020' do
        it "populates 'hesa_ethnicity' with hesa_code '98' when candidate 'prefers not to say'" do
          application_form = create(:application_form,
                                    equality_and_diversity: {
                                      ethnic_group: 'Prefer not to say',
                                      disabilities: [],
                                    })

          cycle_year = 2020

          described_class.call(cycle_year)

          application_form.reload

          expect(application_form.equality_and_diversity).to eq(
            'ethnic_group' => 'Prefer not to say',
            'disabilities' => [],
            'hesa_disabilities' => nil,
            'hesa_ethnicity' => described_class::HESA_ETHNICITY_CODE_REFUSED,
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

          cycle_year = 2021

          described_class.call(cycle_year)

          application_form.reload

          expect(application_form.equality_and_diversity).to eq(
            'ethnic_group' => 'Prefer not to say',
            'disabilities' => [],
            'hesa_disabilities' => nil,
            'hesa_ethnicity' => nil,
            'hesa_sex' => nil,
          )
        end
      end
    end
  end
end
