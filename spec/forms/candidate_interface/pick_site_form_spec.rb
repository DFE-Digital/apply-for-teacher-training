require 'rails_helper'

RSpec.describe CandidateInterface::PickSiteForm, type: :model do
  describe '.available_sites' do
    it 'returns available course options for the provided course/study mode combo' do
      available = create(:course_option, :full_time)
      create(:course_option, :no_vacancies, course: available.course, study_mode: available.study_mode)
      create(:course_option, site_still_valid: false, course: available.course, study_mode: available.study_mode)

      expect(described_class.available_sites(available.course, available.study_mode))
        .to eq [available]
    end
  end

  describe '#valid?' do
    it 'checks if the user has no more than 3 choices' do
      application_form = create(:application_form)
      application_form.application_choices << create(:application_choice)
      application_form.application_choices << create(:application_choice)

      pick_site_form = described_class.new(
        application_form: application_form,
        course_option_id: create(:course_option).id,
      )

      expect(pick_site_form).to be_valid(:save)

      pick_site_form.save

      pick_site_form = described_class.new(
        application_form: application_form,
        course_option_id: create(:course_option).id,
      )

      expect(pick_site_form).not_to be_valid(:save)
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form) }
    let(:course_option) { create(:course_option) }

    it 'sets course_option on the new course choice' do
      described_class.new(
        application_form: application_form,
        course_option_id: course_option.id,
      ).save

      application_choice = application_form.reload.application_choices.first
      expect(application_choice.course_option.id).to eq(course_option.id)
      expect(application_choice.current_course_option_id).to eq(course_option.id)
    end

    it 'sets provider_ids when creating the application choice' do
      described_class.new(
        application_form: application_form,
        course_option_id: course_option.id,
      ).save

      application_choice = application_form.reload.application_choices.first
      expect(application_choice.provider_ids).not_to be_empty
    end
  end

  describe '#update' do
    let(:application_choice) { create(:application_choice) }
    let(:new_course_option) { create(:course_option) }

    it 'updates the course_option for an existing course choice' do
      expect(application_choice.course_option.id).not_to eq(new_course_option.id)

      described_class.new(
        application_form: application_choice.application_form,
        course_option_id: new_course_option.id,
      ).update(application_choice)

      expect(application_choice.course_option.id).to eq(new_course_option.id)
      expect(application_choice.current_course_option_id).to eq(new_course_option.id)
    end

    it 'updates provider_ids for existing course choice' do
      expect(application_choice.course_option.id).not_to eq(new_course_option.id)

      expect {
        described_class.new(
          application_form: application_choice.application_form,
          course_option_id: new_course_option.id,
        ).update(application_choice)
      }.to change(application_choice, :provider_ids)
    end
  end
end
