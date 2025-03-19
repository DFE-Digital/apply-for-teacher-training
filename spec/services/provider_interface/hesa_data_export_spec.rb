require 'rails_helper'

RSpec.describe ProviderInterface::HesaDataExport do
  shared_examples_for 'an exported HESA row' do
    it 'includes candidate and HESA data' do
      expect(export_row['id']).to eq(application_with_offer.id)
      expect(export_row['status']).to eq(application_with_offer.status)
      expect(export_row['first_name']).to eq(application_with_offer.application_form.first_name)
      expect(export_row['last_name']).to eq(application_with_offer.application_form.last_name)
      expect(export_row['date_of_birth']).to eq(application_with_offer.application_form.date_of_birth)
      expect(export_row['nationality']).to eq(decorated_application.nationality)
      expect(export_row['domicile']).to eq(application_with_offer.application_form.domicile)
      expect(export_row['email']).to eq(application_with_offer.application_form.candidate.email_address)
      expect(export_row['recruitment_cycle_year']).to eq(application_with_offer.application_form.recruitment_cycle_year)
      expect(export_row['provider_code']).to eq(application_with_offer.provider.code)
      expect(export_row['accredited_provider_name']).to eq(application_with_offer.course.accredited_provider.name)
      expect(export_row['course_code']).to eq(course.code)
      expect(export_row['site_code']).to eq(application_with_offer.site.code)
      expect(export_row['study_mode']).to eq('01')
      expect(export_row['SBJCA']).to eq('100425 101277')
      expect(export_row['QLAIM']).to eq('021')
      expect(export_row['FIRSTDEG']).to eq(1)
      expect(export_row['DEGTYPE']).to eq('007')
      expect(export_row['DEGSBJ']).to eq('100100')
      expect(export_row['DEGCLSS']).to eq('02')
      expect(export_row['institution_country']).to eq('GB')
      expect(export_row['DEGSTDT']).to eq('2010-01-01')
      expect(export_row['DEGENDDT']).to eq('2013-01-01')
      expect(export_row['institution_details']).to eq('0001')
      expect(export_row['sex']).to eq(1)
      expect(export_row['disabilities']).to eq('53 55 54')
      expect(export_row['ethnicity']).to eq(15)
    end
  end

  let(:provider_relationship) { create(:provider_relationship_permissions, ratifying_provider_can_view_diversity_information: true) }
  let(:training_provider) { provider_relationship.training_provider }
  let(:accredited_provider) { provider_relationship.ratifying_provider }
  let(:provider_user) { create(:provider_user, :with_view_diversity_information, providers: [training_provider]) }
  let(:hesa_disabilities) { [53, 55, 54] }
  let(:decorated_application) { ApplicationChoiceHesaExportDecorator.new(application_with_offer) }
  let(:application_with_offer) do
    create(:application_choice,
           :accepted,
           application_form: create(:completed_application_form),
           course_option:)
  end
  let(:subjects) { [create(:subject, code: 'F3'), create(:subject, code: 'X9')] }
  let(:application_qualification) do
    create(:application_qualification,
           level: 'degree',
           qualification_type_hesa_code: '007',
           subject_hesa_code: '100100',
           grade_hesa_code: '02',
           institution_country: 'GB',
           start_year: '2010',
           award_year: '2013',
           institution_hesa_code: '0001')
  end
  let(:course_option) { create(:course_option, course:) }
  let(:course) { create(:course, study_mode: 'full_time', subjects:, provider: training_provider, accredited_provider:) }

  before do
    application_with_offer.application_form.application_qualifications << application_qualification
    application_with_offer.application_form.update(equality_and_diversity: {
      hesa_sex: 1, hesa_disabilities:, hesa_ethnicity: 15
    })
  end

  describe '#export_row' do
    subject(:export_row) { described_class.new(actor: provider_user).export_row(application_with_offer) }

    context 'for the current recruitment cycle year' do
      let(:course) do
        create(:course,
               study_mode: 'full_time',
               subjects:,
               provider: training_provider,
               accredited_provider:)
      end

      subject(:export_row) { described_class.new(actor: provider_user).export_row(application_with_offer) }

      it_behaves_like 'an exported HESA row'
    end

    context 'for the specified recruitment cycle year' do
      context 'when the recruitment cycle has data' do
        let(:course) do
          create(:course,
                 study_mode: 'full_time',
                 subjects:,
                 provider: training_provider,
                 accredited_provider:,
                 recruitment_cycle_year: 2019)
        end

        subject(:export_row) { described_class.new(actor: provider_user, recruitment_cycle_year: 2019).export_row(application_with_offer) }

        it_behaves_like 'an exported HESA row'
      end

      context 'when the recruitment cycle has no data' do
        subject(:export_row) { described_class.new(actor: provider_user, recruitment_cycle_year: 2018).export_row(nil) }

        it 'has no data' do
          expect(export_row).to be_empty
        end
      end
    end

    context 'when application is the degree apprenticeship and does not have a degree' do
      let(:application_without_a_degree) do
        create(:application_choice,
               :accepted,
               application_form: create(:application_form, :minimum_info),
               course_option:)
      end

      subject(:export_row) do
        described_class.new(actor: provider_user, recruitment_cycle_year: 2018).export_row(application_without_a_degree)
      end

      %w[DEGTYPE DEGSBJ DEGCLSS institution_country DEGSTDT DEGENDDT institution_details].each do |field|
        it "export the row setting HESA field '#{field}' to 'no degree'" do
          expect(export_row[field]).to eq('no degree')
        end
      end

      it 'export the row as the degree section is incomplete' do
        expect(export_row['FIRSTDEG']).to be_zero
      end

      it 'export the row with application fields' do
        expect(export_row['id']).to eq(application_without_a_degree.id)
        expect(export_row['status']).to eq(application_without_a_degree.status)
        expect(export_row['first_name']).to eq(application_without_a_degree.application_form.first_name)
        expect(export_row['last_name']).to eq(application_without_a_degree.application_form.last_name)
        expect(export_row['date_of_birth']).to eq(application_without_a_degree.application_form.date_of_birth)
      end
    end

    context 'when hesa disabilities is stored as string' do
      let(:hesa_disabilities) { '55' }

      it 'exports this value' do
        expect(export_row['disabilities']).to eq('55')
      end
    end

    context 'when user does not have permission to view diversity information' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      it 'shows diversity information as confidential' do
        expect(export_row['sex']).to eq('confidential')
        expect(export_row['disabilities']).to eq('confidential')
        expect(export_row['ethnicity']).to eq('confidential')
      end
    end

    context 'when user is from the accredited provider' do
      let(:provider_user) { create(:provider_user, :with_view_diversity_information, providers: [accredited_provider]) }

      it_behaves_like 'an exported HESA row'
    end

    context 'when there is an unknown subject code' do
      let(:subjects) { [create(:subject, code: 'F3'), create(:subject, code: 'X9'), create(:subject, code: 'missing-value')] }

      it 'ignores unknown subjects' do
        expect(export_row).to include({ 'SBJCA' => '100425 101277' })
      end

      it_behaves_like 'an exported HESA row'
    end
  end

  describe '#export_data' do
    let(:exporter) { described_class.new(actor: provider_user, recruitment_cycle_year: current_year) }
    let(:exported_data) { exporter.export_data }
    let(:export_row) { exporter.export_row(exported_data.first) }

    context 'when provider has courses in multiple recruitment cycles' do
      it 'only exports current recruitment cycle data' do
        previous_cycle_course = create(:course, recruitment_cycle_year: previous_year, provider: training_provider, accredited_provider:)
        course_option = create(:course_option, course: previous_cycle_course)
        create(:application_choice, :accepted, course_option:)

        expect(exported_data.count).to eq 1
      end
    end

    it_behaves_like 'an exported HESA row'
  end
end
