require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoiceItemComponent do
  let(:application_choice) { create(:application_choice, status) }
  let(:component) { described_class.new(application_choice:) }
  let(:rendered) { render_inline(component) }

  shared_examples 'application choice item' do
    it 'displays correct message' do
      expect(rendered.text).to include(t("candidate_application_states.#{application_choice.status}"))
      expect(rendered.text).to include(application_choice.current_course.provider.name)
      expect(rendered.text).to include(application_choice.id.to_s)
      expect(rendered.text).to include(application_choice.current_course.name_and_code)
    end
  end

  it_behaves_like('application choice item') { let(:status) { :unsubmitted } }
  it_behaves_like('application choice item') { let(:status) { :awaiting_provider_decision } }
  it_behaves_like('application choice item') { let(:status) { :interviewing } }
  it_behaves_like('application choice item') { let(:status) { :withdrawn } }

  it_behaves_like('application choice item') { let(:status) { :offer } }

  it_behaves_like('application choice item') { let(:status) { :pending_conditions } }
  it_behaves_like('application choice item') { let(:status) { :offer_withdrawn } }

  it_behaves_like('application choice item') { let(:status) { :rejected } }
  it_behaves_like('application choice item') { let(:status) { :declined } }
  it_behaves_like('application choice item') { let(:status) { :inactive } }

  context 'when the Candidate has chosen the School Placement' do
    let(:application_choice) { create(:application_choice, school_placement_auto_selected: false) }

    it 'displays with the Site name' do
      expect(rendered.text).to include(application_choice.site.name)
    end
  end

  context 'when the Candidate has not chosen the School Placement' do
    let(:application_choice) { create(:application_choice, school_placement_auto_selected: true) }

    it 'displays with the Site name' do
      expect(rendered.text).not_to include(application_choice.site.name)
    end
  end

  context 'when the choice is in offer state and the date is between the Apply deadline and the Decline by default date' do
    let(:application_choice) { create(:application_choice, :offered) }

    it 'displays the response deadline reminder text' do
      decline_by_default_date = RecruitmentCycleTimetable.current_timetable.decline_by_default_at

      travel_temporarily_to(decline_by_default_date - 2.days) do
        expect(rendered.text).to include("Respond before #{decline_by_default_date.to_fs(:govuk_time)} on #{decline_by_default_date.to_fs(:day_and_month)}")
      end
    end
  end

  context 'when the choice is in offer state and the date is not in the relevant period' do
    let(:application_choice) { create(:application_choice, :offered) }

    it 'does not display the response deadline reminder text' do
      decline_by_default_date = RecruitmentCycleTimetable.current_timetable.decline_by_default_at

      travel_temporarily_to(decline_by_default_date + 2.days) do
        expect(rendered.text).not_to include("Respond before #{decline_by_default_date.to_fs(:govuk_time_first_no_year_date_time)}")
      end
    end
  end
end
