require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormPresenter do
  describe '#personal_details_completed?' do
    it 'returns true if personal details section is completed' do
      application_form = FactoryBot.build(:completed_application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_personal_details_completed
    end

    it 'returns false if personal details section is incomplete' do
      application_form = FactoryBot.build(:application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_personal_details_completed
    end
  end

  describe '#contact_details_completed?' do
    it 'returns true if contact details section is completed' do
      application_form = FactoryBot.build(:completed_application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_contact_details_completed
    end

    it 'returns false if contact details section is incomplete' do
      application_form = FactoryBot.build(:application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_contact_details_completed
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
      application_form = FactoryBot.build(:completed_application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).to be_application_choices_added
    end

    it 'returns false if no application choices are added' do
      application_form = FactoryBot.build(:application_form)
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)

      expect(presenter).not_to be_application_choices_added
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
        application_form.references.delete_all
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
  end
end
