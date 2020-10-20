require 'rails_helper'

RSpec.describe ProviderInterface::HesaDataExport do
  describe '#call' do
    let(:provider_ids) { @course.provider.id }

    subject(:export_data) { described_class.new(provider_ids: provider_ids).call }

    before do
      @course = create(:course, study_mode: 'full_time', subject_codes: %w[F3 X9])
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
        :with_offer,
        course_option: course_option,
      )
      @application_with_offer.application_form.application_qualifications << application_qualification
      @application_with_offer.application_form.update(equality_and_diversity: {
        hesa_sex: 1, hesa_disabilities: [53, 55, 54], hesa_ethnicity: 15
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
      exported_data = CSV.parse(export_data)
      cells = exported_data[1]

      expect(cells[0]).to eq(@application_with_offer.application_form.support_reference)
      expect(cells[1]).to eq(@application_with_offer.status)
      expect(cells[2]).to eq(@application_with_offer.application_form.first_name)
      expect(cells[3]).to eq(@application_with_offer.application_form.last_name)
      expect(cells[4]).to eq(@application_with_offer.application_form.date_of_birth.to_s)
      expect(cells[5]).to eq(@application_with_offer.application_form.first_nationality)
      expect(cells[6]).to eq(@application_with_offer.application_form.country)
      expect(cells[7]).to eq(@application_with_offer.application_form.candidate.email_address)
      expect(cells[8]).to eq(@application_with_offer.application_form.recruitment_cycle_year.to_s)
      expect(cells[9]).to eq(@application_with_offer.provider.code)
      expect(cells[11]).to eq(@course.code)
      expect(cells[12]).to eq(@application_with_offer.site.code)
      expect(cells[13]).to eq('01')
      expect(cells[14]).to eq('100425 101277')
      expect(cells[15]).to eq('021')
      expect(cells[16]).to eq('1')
      expect(cells[17]).to eq('007')
      expect(cells[18]).to eq('100100')
      expect(cells[19]).to eq('02')
      expect(cells[20]).to eq('GB')
      expect(cells[21]).to eq('2010')
      expect(cells[22]).to eq('2013')
      expect(cells[23]).to eq('0001')
      expect(cells[24]).to eq('1')
      expect(cells[25]).to eq('53 55 54')
      expect(cells[26]).to eq('15')
    end
  end
end
