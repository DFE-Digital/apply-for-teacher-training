require 'rails_helper'

RSpec.describe CandidateInterface::DegreeTypeForm do
  describe '#save' do
    context 'when the description matches an entry in the HESA data' do
      let(:form) do
        described_class.new(
          type_description: 'Doctor of Divinity',
          application_form: create(:application_form),
        )
      end

      it 'persists both type description and HESA code' do
        form.save

        expect(form.application_form.application_qualifications.degree.size).to eq 1
        degree = form.application_form.application_qualifications.degree.first
        expect(degree.qualification_type).to eq 'Doctor of Divinity'
        expect(degree.qualification_type_hesa_code).to eq 300
      end
    end

    context 'when the description does not match an entry in the HESA data' do
      let(:form) do
        described_class.new(
          type_description: 'Doctor of Rap Battles',
          application_form: create(:application_form),
        )
      end

      it 'persists type description but no HESA code' do
        form.save

        degree = form.application_form.application_qualifications.degree.first
        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to eq nil
      end
    end

    context 'when missing type_description' do
      let(:form) { described_class.new(application_form: build(:application_form)) }

      it 'returns false and has errors' do
        expect(form.save).to eq false
        expect(form.errors.full_messages).to eq ['Type description Enter your degree type']
      end
    end

    context 'when missing application_form' do
      let(:form) { described_class.new(type_description: 'BSc') }

      it 'returns false and has errors' do
        expect(form.save).to eq false
        expect(form.errors.full_messages).to eq ['Application form is missing']
      end
    end
  end

  describe '#update' do
    context 'when the type description matches an entry in the HESA data' do
      let(:degree) do
        create(
          :degree_qualification,
          application_form: create(:application_form),
          qualification_type: 'BSc',
        )
      end
      let(:form) do
        described_class.new(degree: degree, type_description: 'Doctor of Divinity')
      end

      it 'updates the qualification_type and HESA code' do
        form.update

        expect(degree.qualification_type).to eq 'Doctor of Divinity'
        expect(degree.qualification_type_hesa_code).to eq 300
      end
    end

    context 'when the type description does not match an entry in the HESA data' do
      let(:degree) do
        create(
          :degree_qualification,
          application_form: create(:application_form),
          qualification_type: 'BSc',
        )
      end
      let(:form) do
        described_class.new(degree: degree, type_description: 'Doctor of Rap Battles')
      end

      it 'updates the qualification_type' do
        form.update

        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to eq nil
      end
    end

    context 'when missing type_description' do
      let(:form) { described_class.new(degree: build(:degree_qualification)) }

      it 'returns false and has errors' do
        expect(form.update).to eq false
        expect(form.errors.full_messages).to eq ['Type description Enter your degree type']
      end
    end

    context 'when missing application_form' do
      let(:form) { described_class.new(type_description: 'BSc') }

      it 'returns false and has errors' do
        expect(form.update).to eq false
        expect(form.errors.full_messages).to eq ['Degree is missing']
      end
    end

    context 'when UK degree is selected and international_degrees feature flag is active' do
      let(:degree) do
        create(
          :degree_qualification,
          application_form: create(:application_form),
          qualification_type: 'BSc',
        )
      end

      let(:form) do
        described_class.new(degree: degree, type_description: 'Doctor of Rap Battles', uk_degree: 'yes')
      end

      before { FeatureFlag.activate(:international_degrees) }

      it 'updates the qualification_type and sets international to false' do
        form.update

        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to eq nil
        expect(degree.international).to be false
      end
    end

    context 'when non-UK degree is selected and international_degrees feature flag is active' do
      let(:degree) do
        create(
          :degree_qualification,
          application_form: create(:application_form),
          qualification_type: 'BSc',
        )
      end

      let(:form) do
        described_class.new(degree: degree, international_type_description: 'Doctor of Rap Battles', uk_degree: 'no')
      end

      before { FeatureFlag.activate(:international_degrees) }

      it 'updates the qualification_type and sets international to false' do
        form.update

        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to eq nil
        expect(degree.international).to be true
      end
    end
  end
end
