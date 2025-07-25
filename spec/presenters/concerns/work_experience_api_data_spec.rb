require 'rails_helper'

RSpec.describe WorkExperienceAPIData do
  subject(:presenter) { WorkExperienceAPIDataClass.new(application_choice, active_version) }

  let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision, application_form:) }
  let(:work_experience_class) do
    Class.new do
      include WorkExperienceAPIData

      attr_accessor :application_choice, :application_form, :active_version

      def initialize(application_choice, active_version)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
        @active_version = active_version
      end
    end
  end
  let(:active_version) { '1.0' }

  before do
    stub_const('WorkExperienceAPIDataClass', work_experience_class)
  end

  describe '#work_history_break_explanation' do
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:april2019) { Time.zone.local(2019, 4, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:december2019) { Time.zone.local(2019, 12, 1) }
    let(:application_form) do
      build_stubbed(:application_form,
                    :with_completed_references,
                    work_history_breaks:,
                    application_work_history_breaks: breaks)
    end

    context 'when the work history breaks field has a value' do
      let(:work_history_breaks) { 'I was sleeping.' }
      let(:breaks) { [] }

      it 'returns the work_history_breaks attribute of an application' do
        expect(presenter.work_history_break_explanation).to eq('I was sleeping.')
      end
    end

    context 'when the work history breaks field has a value over the desired 10240 character limit' do
      let(:work_history_breaks) { 'I was sleeping.' * 1000 }
      let(:breaks) { [] }

      it 'returns the work_history_breaks attribute of an application' do
        presenter.work_history_break_explanation

        expect(presenter.work_history_break_explanation).to end_with(described_class::OMISSION_TEXT)
        expect(presenter.work_history_break_explanation.length).to be(10240)
      end
    end

    context 'when individual breaks have been entered' do
      let(:work_history_breaks) { nil }
      let(:breaks) { [break1, break2] }
      let(:break1) { build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019, reason: 'I was watching TV.') }
      let(:break2) { build_stubbed(:application_work_history_break, start_date: september2019, end_date: december2019, reason: 'I was playing games.') }

      it 'returns a concatenation of application_work_history_breaks of an application' do
        expect(presenter.work_history_break_explanation).to eq(
          "February 2019 to April 2019: I was watching TV.\n\nSeptember 2019 to December 2019: I was playing games.",
        )
      end
    end

    context 'when no breaks have been entered' do
      let(:work_history_breaks) { nil }
      let(:breaks) { [] }

      it 'returns an empty string' do
        expect(presenter.work_history_break_explanation).to eq('')
      end
    end
  end

  describe '#work_experience_jobs' do
    context 'when there is no work experience' do
      let(:application_form) { create(:application_form, :minimum_info, application_work_experiences: []) }

      it 'returns an empty array' do
        expect(presenter.work_experience_jobs).to eq([])
      end
    end

    context 'when there is work experience' do
      let!(:application_form) { create(:application_form, :minimum_info, application_work_experiences: [work_experience]) }
      let(:work_experience) do
        build(:application_work_experience,
              relevant_skills: nil,
              start_date: Time.zone.local(2020, 12, 1),
              start_date_unknown: false,
              end_date: Time.zone.local(2021, 1, 1),
              end_date_unknown: nil,
              currently_working: false)
      end

      %w[1.0 1.1 1.2].each do |version|
        context "for version #{version}" do
          let(:active_version) { version }

          it 'returns the work experience as a hash' do
            expected_work_experience = {
              id: work_experience.id,
              start_date: Time.zone.local(2020, 12, 1),
              end_date: Time.zone.local(2021, 1, 1),
              role: work_experience.role,
              organisation_name: work_experience.organisation,
              working_with_children: work_experience.working_with_children,
              commitment: work_experience.commitment,
              description: work_experience.details,
            }

            expect(presenter.work_experience_jobs).to eq([expected_work_experience])
          end
        end
      end

      context 'for version 1.3' do
        let(:active_version) { '1.3' }

        it 'returns the work experience as a hash' do
          expected_work_experience = {
            id: work_experience.id,
            start_date: Time.zone.local(2020, 12, 1),
            end_date: Time.zone.local(2021, 1, 1),
            start_month: {
              year: '2020',
              month: '12',
              estimated: false,
            },
            end_month: {
              year: '2021',
              month: '01',
              estimated: nil,
            },
            role: work_experience.role,
            organisation_name: work_experience.organisation,
            working_with_children: work_experience.working_with_children,
            commitment: work_experience.commitment,
            description: work_experience.details,
            skills_relevant_to_teaching: nil,
          }

          expect(presenter.work_experience_jobs).to eq([expected_work_experience])
        end
      end
    end
  end

  describe '#work_experience_volunteering' do
    context 'when there is no volunteering experience' do
      let(:application_form) { create(:application_form, :minimum_info, application_volunteering_experiences: []) }

      it 'returns an empty array' do
        expect(presenter.work_experience_volunteering).to eq([])
      end
    end

    context 'when there is volunteering experience' do
      let!(:application_form) { create(:application_form, :minimum_info, application_volunteering_experiences: [volunteering_experience]) }
      let(:volunteering_experience) do
        build(:application_volunteering_experience,
              relevant_skills: true,
              start_date: Time.zone.local(2019, 2, 1),
              start_date_unknown: true,
              end_date: nil,
              currently_working: true)
      end

      %w[1.0 1.1 1.2].each do |version|
        context "for version #{version}" do
          let(:active_version) { version }

          it 'returns the volunteering experience as a hash' do
            expected_volunteering_experience = {
              id: volunteering_experience.id,
              start_date: Time.zone.local(2019, 2, 1),
              end_date: nil,
              role: volunteering_experience.role,
              organisation_name: volunteering_experience.organisation,
              working_with_children: volunteering_experience.working_with_children,
              commitment: volunteering_experience.commitment,
              description: "Working pattern: #{volunteering_experience.working_pattern}\n\nDescription: #{volunteering_experience.details}",
            }

            expect(presenter.work_experience_volunteering).to eq([expected_volunteering_experience])
          end
        end
      end

      context 'for version 1.3' do
        let(:active_version) { '1.3' }

        it 'returns the volunteering experience as a hash' do
          expected_volunteering_experience = {
            id: volunteering_experience.id,
            start_date: Time.zone.local(2019, 2, 1),
            end_date: nil,
            start_month: {
              year: '2019',
              month: '02',
              estimated: true,
            },
            end_month: nil,
            role: volunteering_experience.role,
            organisation_name: volunteering_experience.organisation,
            working_with_children: volunteering_experience.working_with_children,
            commitment: volunteering_experience.commitment,
            description: "Working pattern: #{volunteering_experience.working_pattern}\n\nDescription: #{volunteering_experience.details}",
            skills_relevant_to_teaching: true,
          }

          expect(presenter.work_experience_volunteering).to eq([expected_volunteering_experience])
        end
      end
    end
  end
end
