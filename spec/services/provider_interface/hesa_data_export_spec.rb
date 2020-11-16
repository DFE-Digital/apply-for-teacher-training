require 'rails_helper'

RSpec.describe ProviderInterface::HesaDataExport do
  describe '#call' do
    let(:accredited_provider) do
      provider_permissions = create(
        :provider_relationship_permissions,
        ratifying_provider_can_view_diversity_information: true,
      )
      provider_permissions.ratifying_provider
    end
    let(:provider_ids) { @course.provider.id }
    let(:hesa_disabilities) { [53, 55, 54] }
    let(:provider_user) { create(:provider_user, :with_view_diversity_information, providers: [accredited_provider]) }

    subject(:export_data) { described_class.new(provider_ids: provider_ids, actor: provider_user).call }

    before do
      @course = create(:course, study_mode: 'full_time', subject_codes: %w[F3 X9], accredited_provider: accredited_provider)
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
      expect(csv.headers).to eq([
        'id', 'status', 'first name', 'last name', 'date of birth', 'nationality',
        'domicile', 'email address', 'recruitment cycle', 'provider code', 'accredited body',
        'course code', 'site code', 'study mode', 'SBJCA', 'QLAIM', 'FIRSTDEG', 'DEGTYPE',
        'DEGSBJ', 'DEGCLSS', 'institution country', 'DEGSTDT', 'DEGENDDT', 'institution details',
        'sex', 'disabilities', 'ethnicity'
      ])
    end

    it 'includes candidate and HESA data' do
      exported_data = CSV.parse(export_data, headers: true)
      row = exported_data.first

      expect(row['id']).to eq(@application_with_offer.application_form.support_reference)
      expect(row['status']).to eq(@application_with_offer.status)
      expect(row['first name']).to eq(@application_with_offer.application_form.first_name)
      expect(row['last name']).to eq(@application_with_offer.application_form.last_name)
      expect(row['date of birth']).to eq(@application_with_offer.application_form.date_of_birth.to_s)
      expect(row['nationality']).to eq(@application_with_offer.application_form.first_nationality)
      expect(row['domicile']).to eq(@application_with_offer.application_form.country)
      expect(row['email address']).to eq(@application_with_offer.application_form.candidate.email_address)
      expect(row['recruitment cycle']).to eq(@application_with_offer.application_form.recruitment_cycle_year.to_s)
      expect(row['provider code']).to eq(@application_with_offer.provider.code)
      expect(row['accredited body']).to eq(@application_with_offer.course.accredited_provider.name)
      expect(row['course code']).to eq(@course.code)
      expect(row['site code']).to eq(@application_with_offer.site.code)
      expect(row['study mode']).to eq('01')
      expect(row['SBJCA']).to eq('100425 101277')
      expect(row['QLAIM']).to eq('021')
      expect(row['FIRSTDEG']).to eq('1')
      expect(row['DEGTYPE']).to eq('007')
      expect(row['DEGSBJ']).to eq('100100')
      expect(row['DEGCLSS']).to eq('02')
      expect(row['institution country']).to eq('GB')
      expect(row['DEGSTDT']).to eq('2010')
      expect(row['DEGENDDT']).to eq('2013')
      expect(row['institution details']).to eq('0001')
      expect(row['sex']).to eq('1')
      expect(row['disabilities']).to eq('53 55 54')
      expect(row['ethnicity']).to eq('15')
    end

    context 'when hesa disabilities is stored as string' do
      let(:hesa_disabilities) { '55' }

      it 'exports this value' do
        exported_data = CSV.parse(export_data, headers: true)
        expect(exported_data.first['disabilities']).to eq('55')
      end
    end

    context 'when user does not have permission to view diversity information' do
      let(:provider_user) { create(:provider_user, providers: [accredited_provider]) }

      it 'shows diversity information as confidential' do
        exported_data = CSV.parse(export_data, headers: true)
        row = exported_data.first

        expect(row['sex']).to eq('confidential')
        expect(row['disabilities']).to eq('confidential')
        expect(row['ethnicity']).to eq('confidential')
      end
    end
  end
end
