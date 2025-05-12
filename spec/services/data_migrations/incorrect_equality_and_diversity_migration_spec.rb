require 'rails_helper'

RSpec.describe DataMigrations::IncorrectEqualityAndDiversityMigration do
  describe '#change', time: mid_cycle(2024) do
    context 'when outdated hesa sex code' do
      before do
        @male = create(:application_form, equality_and_diversity: { hesa_sex: '1', sex: 'male' }, created_at: 10.days.ago)
        @female = create(:application_form, equality_and_diversity: { hesa_sex: '2', sex: 'female' })
        @intersex = create(:application_form, equality_and_diversity: { hesa_sex: '3', sex: 'intersex' })
        @prefer_not_to_say = create(:application_form, equality_and_diversity: { hesa_sex: nil, sex: 'Prefer not to say' })
      end

      it 'returns the expected records' do
        expect(described_class.new.records).to contain_exactly(@male, @female, @intersex)
      end

      it 'pass a limit in case we want to do in parts' do
        described_class.new.change(limit: 1)

        expect(@male.reload.equality_and_diversity['hesa_sex']).to eq('11')
        expect(@female.reload.equality_and_diversity['hesa_sex']).to eq('2')
        expect(@intersex.reload.equality_and_diversity['hesa_sex']).to eq('3')
        expect(@prefer_not_to_say.reload.equality_and_diversity['hesa_sex']).to be_nil
      end

      it 'creates an audit record' do
        expect {
          described_class.new.change
        }.to change { @male.audits.count }.by(1)

        audit = @male.audits.last
        expect(audit.comment).to eq('E&D fixing incorrect and outdated HESA values')
        expect(audit.action).to eq('update')
        expect(audit.username).to eq('DataMigration')
      end

      it 'converts to the uptodate hesa values' do
        described_class.new.change

        expect(@female.reload.equality_and_diversity['hesa_sex']).to eq('10')
        expect(@male.reload.equality_and_diversity['hesa_sex']).to eq('11')
        expect(@intersex.reload.equality_and_diversity['hesa_sex']).to eq('12')
        expect(@prefer_not_to_say.reload.equality_and_diversity['hesa_sex']).to be_nil
      end
    end

    context 'when up to date hesa sex code' do
      before do
        @female = create(:application_form, equality_and_diversity: { hesa_sex: '10', sex: 'female', hesa_ethnicity: '10' })
        @male = create(:application_form, equality_and_diversity: { hesa_sex: '11', sex: 'male', hesa_ethnicity: '10' })
        @other = create(:application_form, equality_and_diversity: { hesa_sex: '12', sex: 'other', hesa_ethnicity: '10' })
      end

      it 'returns the records' do
        expect(described_class.new.records).to contain_exactly(@male, @female, @other)
      end

      it 'keep the same values' do
        described_class.new.change

        expect(@female.reload.equality_and_diversity['hesa_sex']).to eq('10')
        expect(@male.reload.equality_and_diversity['hesa_sex']).to eq('11')
        expect(@other.reload.equality_and_diversity['hesa_sex']).to eq('12')
      end
    end

    context 'when outdated HESA disabilities codes' do
      before do
        @learning_difficulty = create(:application_form, equality_and_diversity: { disabilities: ['Learning difficulty'] })
        @social_impairment = create(:application_form, equality_and_diversity: { disabilities: ['Social or communication impairment'] })
        @long_standing = create(:application_form, equality_and_diversity: { disabilities: ['Long-standing illness'] })
        @deaf = create(:application_form, equality_and_diversity: { disabilities: ['Deaf'] })
        @blind = create(:application_form, equality_and_diversity: { disabilities: ['Blind'] })
      end

      it 'returns the records' do
        expect(described_class.new.records).to contain_exactly(
          @learning_difficulty,
          @social_impairment,
          @long_standing,
          @deaf,
          @blind,
        )
      end

      it 'convert to the most uptodate HESA values' do
        described_class.new.change
        expect(@learning_difficulty.reload.equality_and_diversity['hesa_disabilities']).to eq(['51'])
        expect(@learning_difficulty.reload.equality_and_diversity['disabilities']).to eq(
          ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'],
        )
        expect(@social_impairment.reload.equality_and_diversity['hesa_disabilities']).to eq(['53'])
        expect(@social_impairment.equality_and_diversity['disabilities']).to eq(
          ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'],
        )
        expect(@long_standing.reload.equality_and_diversity['hesa_disabilities']).to eq(['54'])
        expect(@long_standing.equality_and_diversity['disabilities']).to eq(
          ['Long-term illness'],
        )
        expect(@deaf.reload.equality_and_diversity['hesa_disabilities']).to eq(['57'])
        expect(@deaf.equality_and_diversity['disabilities']).to eq(
          ['Deafness or a serious hearing impairment'],
        )
        expect(@blind.reload.equality_and_diversity['hesa_disabilities']).to eq(['58'])
        expect(@blind.equality_and_diversity['disabilities']).to eq(
          ['Blindness or a visual impairment not corrected by glasses'],
        )
      end
    end

    context 'when uptodated disabilities' do
      before do
        @learning_difficulty = create(:application_form, equality_and_diversity: { disabilities: ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'], hesa_ethnicity: '10' })
        @social_impairment = create(:application_form, equality_and_diversity: { disabilities: ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'], hesa_ethnicity: '10' })
        @long_standing = create(:application_form, equality_and_diversity: { disabilities: ['Long-term illness'], hesa_ethnicity: '10' })
        @physical_disability = create(:application_form, equality_and_diversity: { disabilities: ['Physical disability or mobility issue'], hesa_ethnicity: '10' })
        @deaf = create(:application_form, equality_and_diversity: { disabilities: ['Deafness or a serious hearing impairment'], hesa_ethnicity: '10' })
        @blind = create(:application_form, equality_and_diversity: { disabilities: ['Blindness or a visual impairment not corrected by glasses'], hesa_ethnicity: '10' })
      end

      it 'returns the records' do
        expect(described_class.new.records).to contain_exactly(
          @learning_difficulty,
          @social_impairment,
          @long_standing,
          @physical_disability,
          @deaf,
          @blind,
        )
      end

      it 'keeps the same HESA values' do
        described_class.new.change
        expect(@learning_difficulty.reload.equality_and_diversity['hesa_disabilities']).to eq(['51'])
        expect(@learning_difficulty.reload.equality_and_diversity['disabilities']).to eq(
          ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'],
        )
        expect(@social_impairment.reload.equality_and_diversity['hesa_disabilities']).to eq(['53'])
        expect(@social_impairment.equality_and_diversity['disabilities']).to eq(
          ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'],
        )
        expect(@long_standing.reload.equality_and_diversity['hesa_disabilities']).to eq(['54'])
        expect(@long_standing.equality_and_diversity['disabilities']).to eq(
          ['Long-term illness'],
        )
        expect(@physical_disability.reload.equality_and_diversity['hesa_disabilities']).to eq(['56'])
        expect(@physical_disability.reload.equality_and_diversity['disabilities']).to eq(
          ['Physical disability or mobility issue'],
        )
        expect(@deaf.reload.equality_and_diversity['hesa_disabilities']).to eq(['57'])
        expect(@deaf.equality_and_diversity['disabilities']).to eq(
          ['Deafness or a serious hearing impairment'],
        )
        expect(@blind.reload.equality_and_diversity['hesa_disabilities']).to eq(['58'])
        expect(@blind.equality_and_diversity['disabilities']).to eq(
          ['Blindness or a visual impairment not corrected by glasses'],
        )
      end
    end

    context 'when outdated hesa ethnicity' do
      context 'when white ethnicity old HESA values' do
        it 'migrates to the most up to date value' do
          white = create(:application_form, equality_and_diversity: { ethnic_background: 'White', hesa_ethnicity: '10' })
          american = create(:application_form, equality_and_diversity: { ethnic_background: 'American', hesa_ethnicity: '10' })
          albaninan = create(:application_form, equality_and_diversity: { ethnic_background: 'Albaninan', hesa_ethnicity: '10' })
          another_white_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Albaninan', hesa_ethnicity: '10' })
          uk_white = create(:application_form, equality_and_diversity: { ethnic_background: 'British, English, Northern Irish, Scottish, or Welsh', hesa_ethnicity: '10' })

          described_class.new.change

          expect(white.reload.equality_and_diversity['hesa_ethnicity']).to eq('160')
          expect(american.reload.equality_and_diversity['hesa_ethnicity']).to eq('160')
          expect(american.reload.equality_and_diversity['ethnic_background']).to eq('American')
          expect(albaninan.reload.equality_and_diversity['hesa_ethnicity']).to eq('160')
          expect(another_white_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('160')
          expect(uk_white.reload.equality_and_diversity['hesa_ethnicity']).to eq('160')
        end
      end

      context 'when black ethnicity old HESA values' do
        it 'migrates to the most up to date value' do
          black_british_caribbean = create(:application_form, equality_and_diversity: { ethnic_background: 'Black or Black British - Caribbean', hesa_ethnicity: '21' })
          black_british_african = create(:application_form, equality_and_diversity: { ethnic_background: 'Black or Black British - African', hesa_ethnicity: '22' })
          black_british_african_free_text = create(:application_form, equality_and_diversity: { ethnic_background: 'African', hesa_ethnicity: '22' })
          other_black_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Other Black background', hesa_ethnicity: '29' })
          another_black_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Another Black background', hesa_ethnicity: '29' })

          described_class.new.change

          expect(black_british_caribbean.reload.equality_and_diversity['hesa_ethnicity']).to eq('121')
          expect(black_british_african.reload.equality_and_diversity['hesa_ethnicity']).to eq('120')
          expect(black_british_african_free_text.reload.equality_and_diversity['hesa_ethnicity']).to eq('120')
          expect(other_black_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('139')
          expect(another_black_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('139')
        end
      end

      context 'when asian ethnicity old HESA values' do
        it 'migrates to the most up to date value' do
          asian_british_indian = create(:application_form, equality_and_diversity: { ethnic_background: 'Asian or Asian British - Indian', hesa_ethnicity: '31' })
          asian_british_indian_free_text = create(:application_form, equality_and_diversity: { ethnic_background: 'Indian', hesa_ethnicity: '31' })
          asian_british_pakistani = create(:application_form, equality_and_diversity: { ethnic_background: 'Asian or Asian British - Pakistani', hesa_ethnicity: '32' })
          asian_british_bangladeshi = create(:application_form, equality_and_diversity: { ethnic_background: 'Asian or Asian British - Bangladeshi', hesa_ethnicity: '33' })
          chinese = create(:application_form, equality_and_diversity: { ethnic_background: 'Chinese', hesa_ethnicity: '34' })
          other_asian_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Other Asian background', hesa_ethnicity: '39' })
          another_asian_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Another Asian background', hesa_ethnicity: '39' })

          described_class.new.change

          expect(asian_british_indian.reload.equality_and_diversity['hesa_ethnicity']).to eq('103')
          expect(asian_british_indian_free_text.reload.equality_and_diversity['hesa_ethnicity']).to eq('103')
          expect(asian_british_pakistani.reload.equality_and_diversity['hesa_ethnicity']).to eq('104')
          expect(asian_british_bangladeshi.reload.equality_and_diversity['hesa_ethnicity']).to eq('100')
          expect(chinese.reload.equality_and_diversity['hesa_ethnicity']).to eq('101')
          expect(other_asian_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('119')
          expect(another_asian_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('119')
        end
      end

      context 'when mixed or other ethnicities' do
        it 'converts to the uptodate hesa values' do
          gypsy_or_traveler = create(:application_form, equality_and_diversity: { ethnic_background: 'Gypsy or Traveller', hesa_ethnicity: '15' })
          arab = create(:application_form, equality_and_diversity: { ethnic_background: 'Arab', hesa_ethnicity: '50' })
          other_ethnic_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Other Ethnic background', hesa_ethnicity: '80' })
          mixed_white_black_caribbean = create(:application_form, equality_and_diversity: { ethnic_background: 'Mixed - White and Black Caribbean', hesa_ethnicity: '41' })
          mixed_white_black_caribbean_free_text = create(:application_form, equality_and_diversity: { ethnic_background: 'Black Caribbean and White', hesa_ethnicity: '41' })
          mixed_white_black_african = create(:application_form, equality_and_diversity: { ethnic_background: 'Mixed - White and Black African', hesa_ethnicity: '42' })
          mixed_white_asian = create(:application_form, equality_and_diversity: { ethnic_background: 'Mixed - White and Asian', hesa_ethnicity: '43' })
          mixed_white_asian_free_text = create(:application_form, equality_and_diversity: { ethnic_background: 'Asian and White', hesa_ethnicity: '43' })
          other_mixed_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Other Mixed background', hesa_ethnicity: '49' })
          another_mixed_background = create(:application_form, equality_and_diversity: { ethnic_background: 'Another Mixed background', hesa_ethnicity: '49' })
          latin = create(:application_form, equality_and_diversity: { ethnic_background: 'Latin American', hesa_ethnicity: '80' })

          described_class.new.change

          expect(gypsy_or_traveler.reload.equality_and_diversity['hesa_ethnicity']).to eq('163')
          expect(mixed_white_black_caribbean.reload.equality_and_diversity['hesa_ethnicity']).to eq('142')
          expect(mixed_white_black_caribbean_free_text.reload.equality_and_diversity['hesa_ethnicity']).to eq('142')

          expect(mixed_white_black_african.reload.equality_and_diversity['hesa_ethnicity']).to eq('141')
          expect(mixed_white_asian.reload.equality_and_diversity['hesa_ethnicity']).to eq('140')
          expect(mixed_white_asian_free_text.reload.equality_and_diversity['hesa_ethnicity']).to eq('140')

          expect(other_mixed_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('159')
          expect(another_mixed_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('159')
          expect(arab.reload.equality_and_diversity['hesa_ethnicity']).to eq('180')
          expect(other_ethnic_background.reload.equality_and_diversity['hesa_ethnicity']).to eq('899')
          expect(latin.reload.equality_and_diversity['hesa_ethnicity']).to eq('899')
        end
      end

      context 'when prefer not to say ethnicities' do
        it 'converts to the uptodate hesa values' do
          prefer_not_to_say = create(:application_form, equality_and_diversity: { ethnic_background: 'Prefer not to say', hesa_ethnicity: '98' })

          described_class.new.change

          expect(prefer_not_to_say.reload.equality_and_diversity['hesa_ethnicity']).to eq('998')
        end
      end
    end
  end
end
