require 'rails_helper'

RSpec.describe CandidateInterface::UpdateEnglishProficiencies do
  before do
    Feature.find_or_create_by(name: 'application_form_has_many_english_proficiencies', active: true)
  end

  after do
    FeatureFlag.deactivate(:application_form_has_many_english_proficiencies)
  end

  describe '#call' do
    subject(:call) do
      described_class.new(
        application_form:,
        qualification_statuses:,
        english_proficiency:,
        efl_qualification:,
        no_qualification_details:,
        persist:,
        publish:,
      ).call
    end

    let(:application_form) { create(:application_form) }
    let(:qualification_statuses) { ['qualification_not_needed'] }
    let(:english_proficiency) { nil }
    let(:efl_qualification) { nil }
    let(:no_qualification_details) { nil }
    let(:persist) { false }
    let(:publish) { false }

    context 'when a english proficiency is not given' do
      context 'when the qualification statuses is "qualification_not_needed"' do
        it 'creates a new published english proficiency with the qualification_not_needed attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiencies.draft.count).to eq(0)

          new_english_proficiency = application_form.english_proficiency
          expect(new_english_proficiency.qualification_not_needed).to be(true)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(false)
          expect(new_english_proficiency.has_qualification).to be(false)
          expect(new_english_proficiency.draft).to be(false)
        end
      end

      context 'when the qualification statuses is "no_qualification"' do
        let(:qualification_statuses) { ['no_qualification'] }

        it 'creates a new draft english proficiency with the no_qualification attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.qualification_not_needed).to be(false)
          expect(new_english_proficiency.no_qualification).to be(true)
          expect(new_english_proficiency.degree_taught_in_english).to be(false)
          expect(new_english_proficiency.has_qualification).to be(false)
          expect(new_english_proficiency.draft).to be(true)
        end
      end

      context 'when the qualification statuses is "no_qualification", and publish is true' do
        let(:publish) { true }
        let(:qualification_statuses) { ['no_qualification'] }

        it 'creates a new published english proficiency with the no_qualification attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          new_english_proficiency = application_form.english_proficiency
          expect(new_english_proficiency.qualification_not_needed).to be(false)
          expect(new_english_proficiency.no_qualification).to be(true)
          expect(new_english_proficiency.degree_taught_in_english).to be(false)
          expect(new_english_proficiency.has_qualification).to be(false)
          expect(new_english_proficiency.draft).to be(false)
        end
      end

      context 'when the qualification statuses is "degree_taught_in_english"' do
        let(:qualification_statuses) { ['degree_taught_in_english'] }

        it 'creates a new draft english proficiency with the degree_taught_in_english attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.qualification_not_needed).to be(false)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(true)
          expect(new_english_proficiency.has_qualification).to be(false)
          expect(new_english_proficiency.draft).to be(true)
        end
      end

      context 'when the qualification statuses is "degree_taught_in_english", and publish is true' do
        let(:publish) { true }
        let(:qualification_statuses) { ['degree_taught_in_english'] }

        it 'creates a published draft english proficiency with the degree_taught_in_english attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          new_english_proficiency = application_form.english_proficiency
          expect(new_english_proficiency.qualification_not_needed).to be(false)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(true)
          expect(new_english_proficiency.has_qualification).to be(false)
          expect(new_english_proficiency.draft).to be(false)
        end
      end

      context 'when the qualification statuses is "has_qualification"' do
        let(:qualification_statuses) { ['has_qualification'] }

        it 'creates a new draft english proficiency with the has_qualification attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.qualification_not_needed).to be(false)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(false)
          expect(new_english_proficiency.has_qualification).to be(true)
          expect(new_english_proficiency.draft).to be(true)
        end
      end

      context 'when the qualification statuses is "has_qualification", and publish is true' do
        let(:publish) { true }
        let(:qualification_statuses) { ['has_qualification'] }

        it 'creates a new published english proficiency with the has_qualification attribute toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          new_english_proficiency = application_form.english_proficiency
          expect(new_english_proficiency.qualification_not_needed).to be(false)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(false)
          expect(new_english_proficiency.has_qualification).to be(true)
          expect(new_english_proficiency.draft).to be(false)
        end
      end

      context 'when multiple qualification statuses have been selected' do
        let(:qualification_statuses) { %w[has_qualification qualification_not_needed degree_taught_in_english] }

        it 'creates a new draft english proficiency with the given attributes toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.qualification_not_needed).to be(true)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(true)
          expect(new_english_proficiency.has_qualification).to be(true)
          expect(new_english_proficiency.draft).to be(true)
        end
      end

      context 'when multiple qualification statuses have been selected, and publish is true' do
        let(:publish) { true }
        let(:qualification_statuses) { %w[has_qualification qualification_not_needed degree_taught_in_english] }

        it 'creates a new draft english proficiency with the given attributes toggled' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          new_english_proficiency = application_form.english_proficiency
          expect(new_english_proficiency.qualification_not_needed).to be(true)
          expect(new_english_proficiency.no_qualification).to be(false)
          expect(new_english_proficiency.degree_taught_in_english).to be(true)
          expect(new_english_proficiency.has_qualification).to be(true)
          expect(new_english_proficiency.draft).to be(false)
        end
      end
    end

    context 'when an english proficiency is given' do
      context 'when the english proficiency is in a draft state' do
        let(:english_proficiency) { create(:english_proficiency, :draft) }

        it 'updates and published the given english proficiency' do
          expect { call }.not_to change(application_form.english_proficiencies, :count)
          expect(english_proficiency.qualification_not_needed).to be(true)
          expect(english_proficiency.no_qualification).to be(false)
          expect(english_proficiency.degree_taught_in_english).to be(false)
          expect(english_proficiency.has_qualification).to be(false)
          expect(english_proficiency.draft).to be(false)
        end
      end

      context 'when the english proficiency is in a draft state, and the qualification statuses is "no_qualification"' do
        let(:qualification_statuses) { ['no_qualification'] }
        let(:english_proficiency) { create(:english_proficiency, :draft) }

        it 'updates the given english proficiency' do
          expect { call }.not_to change(application_form.english_proficiencies, :count)
          expect(english_proficiency.qualification_not_needed).to be(false)
          expect(english_proficiency.no_qualification).to be(true)
          expect(english_proficiency.degree_taught_in_english).to be(false)
          expect(english_proficiency.has_qualification).to be(false)
          expect(english_proficiency.draft).to be(true)
        end
      end

      context 'when the english proficiency is in a draft state, and publish is true' do
        let(:publish) { true }
        let(:qualification_statuses) { ['no_qualification'] }
        let(:english_proficiency) { create(:english_proficiency, :draft) }

        it 'updates the given english proficiency' do
          expect { call }.not_to change(application_form.english_proficiencies, :count)
          expect(english_proficiency.qualification_not_needed).to be(false)
          expect(english_proficiency.no_qualification).to be(true)
          expect(english_proficiency.degree_taught_in_english).to be(false)
          expect(english_proficiency.has_qualification).to be(false)
          expect(english_proficiency.draft).to be(false)
        end
      end
    end

    context 'when an efl qualification is given' do
      let(:efl_qualification) { create(:ielts_qualification) }

      context 'when the qualification status is "has_qualification"' do
        let(:qualification_statuses) { ['has_qualification'] }

        it 'assigns the efl qualification' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.efl_qualification).to eq(efl_qualification)
        end
      end

      context 'when the qualification status is not "has_qualification"' do
        let(:qualification_statuses) { ['no_qualification'] }

        it 'assigns the efl qualification' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.efl_qualification).to be_nil
        end
      end

      context 'when persist is true' do
        let(:persist) { true }
        let(:qualification_statuses) { ['has_qualification'] }

        it 'assigns the efl qualification' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)
          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.efl_qualification).to be_nil
        end
      end
    end

    context 'when "no_qualification_details" are given' do
      let(:no_qualification_details) { 'Work in progress' }

      context 'when the qualification status is "no_qualification"' do
        let(:qualification_statuses) { ['no_qualification'] }

        it 'assigns the "no_qualification_details"' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.no_qualification_details).to eq('Work in progress')
        end
      end

      context 'when the qualification status is "degree_taught_in_english"' do
        let(:qualification_statuses) { ['degree_taught_in_english'] }

        it 'assigns the "no_qualification_details"' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.no_qualification_details).to eq('Work in progress')
        end
      end

      context 'when the qualification status is no "degree_taught_in_english" or "no_qualification"' do
        let(:qualification_statuses) { ['has_qualification'] }

        it 'does not assign the "no_qualification_details"' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.no_qualification_details).to be_nil
        end
      end

      context 'when persist is true' do
        let(:qualification_statuses) { ['degree_taught_in_english'] }
        let(:persist) { true }

        it 'does not assign the "no_qualification_details"' do
          expect { call }.to change(application_form.english_proficiencies, :count).by(1)

          expect(application_form.english_proficiency).to be_nil

          new_english_proficiency = application_form.english_proficiencies.last
          expect(new_english_proficiency.no_qualification_details).to be_nil
        end
      end
    end
  end
end
