require 'rails_helper'

RSpec.describe ProviderInterface::HesaDataExport do
  describe '#call' do
    let(:provider_relationship) { create(:provider_relationship_permissions, ratifying_provider_can_view_diversity_information: true) }
    let(:training_provider) { provider_relationship.training_provider }
    let(:accredited_provider) { provider_relationship.ratifying_provider }
    let(:provider_user) { create(:provider_user, :with_view_diversity_information, providers: [training_provider]) }
    let(:hesa_disabilities) { [53, 55, 54] }
    let(:decorated_application) { ApplicationChoiceHesaExportDecorator.new(@application_with_offer) }

    subject(:export_data) { described_class.new(actor: provider_user).call }

    shared_examples_for 'a full HESA export' do
      it 'includes candidate and HESA data' do
        exported_data = CSV.parse(export_data, headers: true)
        row = exported_data.first

        expect(row['id']).to eq(@application_with_offer.application_form.support_reference)
        expect(row['status']).to eq(@application_with_offer.status)
        expect(row['first_name']).to eq(@application_with_offer.application_form.first_name)
        expect(row['last_name']).to eq(@application_with_offer.application_form.last_name)
        expect(row['date_of_birth']).to eq(@application_with_offer.application_form.date_of_birth.to_s)
        expect(row['nationality']).to eq(decorated_application.nationality)
        expect(row['domicile']).to eq(@application_with_offer.application_form.domicile)
        expect(row['email']).to eq(@application_with_offer.application_form.candidate.email_address)
        expect(row['recruitment_cycle_year']).to eq(@application_with_offer.application_form.recruitment_cycle_year.to_s)
        expect(row['provider_code']).to eq(@application_with_offer.provider.code)
        expect(row['accredited_provider_name']).to eq(@application_with_offer.course.accredited_provider.name)
        expect(row['course_code']).to eq(@course.code)
        expect(row['site_code']).to eq(@application_with_offer.site.code)
        expect(row['study_mode']).to eq('01')
        expect(row['SBJCA']).to eq('100425 101277')
        expect(row['QLAIM']).to eq('021')
        expect(row['FIRSTDEG']).to eq('1')
        expect(row['DEGTYPE']).to eq('007')
        expect(row['DEGSBJ']).to eq('100100')
        expect(row['DEGCLSS']).to eq('02')
        expect(row['institution_country']).to eq('GB')
        expect(row['DEGSTDT']).to eq('2010-01-01')
        expect(row['DEGENDDT']).to eq('2013-01-01')
        expect(row['institution_details']).to eq('0001')
        expect(row['sex']).to eq('1')
        expect(row['disabilities']).to eq('53 55 54')
        expect(row['ethnicity']).to eq('15')
      end
    end

    before do
      @course = create(:course, study_mode: 'full_time', subject_codes: %w[F3 X9], provider: training_provider, accredited_provider: accredited_provider)
      application_qualification = create(
        :application_qualification,
        level: 'degree',
        qualification_type_hesa_code: '007',
        subject_hesa_code: '100100',
        grade_hesa_code: '02',
        institution_country: 'GB',
        start_year: '2010',
        award_year: '2013',
        institution_hesa_code: '0001',
      )
      course_option = create(:course_option, course: @course)
      @application_with_offer = create(
        :application_choice,
        :with_completed_application_form,
        :with_accepted_offer,
        course_option: course_option,
      )
      @application_with_offer.application_form.application_qualifications << application_qualification
      @application_with_offer.application_form.update(equality_and_diversity: {
        hesa_sex: 1, hesa_disabilities: hesa_disabilities, hesa_ethnicity: 15
      })
    end

    it 'generates CSV headers' do
      csv = CSV.parse(export_data, headers: true)
      expect(csv.headers).to eq(%w[id status first_name last_name date_of_birth nationality
                                   domicile email recruitment_cycle_year provider_code accredited_provider_name course_code site_code
                                   study_mode SBJCA QLAIM FIRSTDEG DEGTYPE DEGSBJ DEGCLSS institution_country DEGSTDT DEGENDDT
                                   institution_details sex disabilities ethnicity])
    end

    it_behaves_like 'a full HESA export'

    context 'when hesa disabilities is stored as string' do
      let(:hesa_disabilities) { '55' }

      it 'exports this value' do
        exported_data = CSV.parse(export_data, headers: true)
        expect(exported_data.first['disabilities']).to eq('55')
      end
    end

    context 'when user does not have permission to view diversity information' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      it 'shows diversity information as confidential' do
        exported_data = CSV.parse(export_data, headers: true)
        row = exported_data.first

        expect(row['sex']).to eq('confidential')
        expect(row['disabilities']).to eq('confidential')
        expect(row['ethnicity']).to eq('confidential')
      end
    end

    context 'when user is from the accredited provider' do
      let(:provider_user) { create(:provider_user, :with_view_diversity_information, providers: [accredited_provider]) }

      it_behaves_like 'a full HESA export'
    end

    context 'when provider has courses in multiple recruitment cycles' do
      it 'only exports current recruitment cycle data' do
        previous_cycle_course = create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year, provider: training_provider, accredited_provider: accredited_provider)
        course_option = create(:course_option, course: previous_cycle_course)
        create(:application_choice, :with_accepted_offer, course_option: course_option)

        exported_data = CSV.parse(export_data, headers: true)
        expect(exported_data.count).to eq 1
      end
    end
  end
end
