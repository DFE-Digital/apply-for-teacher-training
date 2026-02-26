require 'rails_helper'

RSpec.describe RecruitmentPerformanceReportExport do
  let(:provider) { create(:provider) }
  let(:region) { Publications::RegionalRecruitmentPerformanceReport.all_of_england_key }
  let(:provider_report) { nil }
  let(:report_type) { :NATIONAL }

  describe '.call' do
    subject(:call) { described_class.new(provider:, region:, provider_report:, report_type:).call }

    context 'when the provider report does not exist' do
      it 'returns nil' do
        expect(call).to be_nil
      end
    end

    context 'when the provider report exists' do
      let(:provider_report) do
        create(:provider_recruitment_performance_report, provider:, recruitment_cycle_year: 2025)
      end
      let(:regional_report) do
        create(
          :regional_recruitment_performance_report,
          cycle_week: provider_report.cycle_week,
          recruitment_cycle_year: provider_report.recruitment_cycle_year,
        )
      end
      let(:national_report) do
        create(
          :national_recruitment_performance_report,
          cycle_week: provider_report.cycle_week,
          recruitment_cycle_year: provider_report.recruitment_cycle_year,
        )
      end

      before do
        provider_report
        regional_report
        national_report
      end

      around { |example| Timecop.freeze { example.run } }

      after do
        FileUtils.rm_rf(Rails.root.join("tmp/#{Time.zone.today}-rpr-export").to_s)
      end

      context 'when the region is all of england' do
        it 'exports the report' do
          zip_file = call
          expect(zip_file).to be_a(String)
          expect(File.exist?(zip_file)).to be(true)

          described_class::REPORTS.each do |report|
            csv_filename = "#{report}_*.csv"
            expect(zip_file).to have_csv_files(csv_filename)
          end
        end

        it 'exports a candidates_who_have_submitted_applications report' do
          zip_file = call
          csv_filename = 'candidates_who_have_submitted_applications_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'All providers', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 58 15 -74% 13364 13214 -1%],
              %w[Secondary 136 50 -63% 19091 25242 32%],
              ['Art & Design', '4', '5', '25%', '706', '1129', '60%'],
              %w[Biology 16 3 -81% 1622 2540 57%],
              %w[Chemistry 6 1 -83% 1442 2077 44%],
              %w[Computing 6 0 -100% 924 1395 51%],
              ['Design & Technology', '3', '2', '-33%', '684', '880', '29%'],
              %w[Drama 3 1 -67% 423 446 5%],
              %w[English 17 6 -65% 3126 3480 11%],
              %w[Geography 8 2 -75% 1096 1306 19%],
              %w[History 5 4 -20% 1205 1314 9%],
              %w[Mathematics 17 2 -88% 3497 4789 37%],
              ['Modern Foreign Languages', '3', '1', '-67%', '1503', '2071', '38%'],
              %w[Music 3 1 -67% 315 407 29%],
              %w[Others 23 13 -43% 920 1072 17%],
              ['Physical Education', '13', '6', '-54%', '2109', '2547', '21%'],
              %w[Physics 14 3 -79% 1490 3923 163%],
              ['Religious Education', '5', '2', '-60%', '491', '887', '81%'],
              ['All subjects', '192', '65', '-66%', '30904', '36044', '17%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a candidates_that_received_an_offer report' do
          zip_file = call
          csv_filename = 'candidates_that_received_an_offer_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'All providers', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 8 8 0% 7949 7311 -8%],
              %w[Secondary 25 25 0% 9971 11229 13%],
              ['Art & Design', '1', '3', '200%', '361', '523', '45%'],
              ['Biology', '0', '1', 'Not available', '619', '824', '33%'],
              ['Design & Technology', '0', '1', 'Not available', '377', '379', '1%'],
              %w[English 3 4 33% 1501 1564 4%],
              %w[Geography 1 2 100% 582 567 -3%],
              %w[History 2 2 0% 708 694 -2%],
              %w[Mathematics 1 1 0% 1312 1540 17%],
              %w[Music 1 1 0% 177 234 32%],
              %w[Others 7 4 -43% 323 316 -2%],
              ['Physical Education', '6', '4', '-33%', '1382', '1348', '-2%'],
              %w[Physics 1 1 0% 438 806 84%],
              ['Religious Education', '2', '1', '-50%', '210', '313', '49%'],
              ['All subjects', '33', '33', '0%', '18123', '18678', '3%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a proportion_of_candidates_with_an_offer report' do
          zip_file = call
          csv_filename = 'proportion_of_candidates_with_an_offer_*.csv'
          csv_data =
            [
              ['', provider.name, '', 'All providers', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Last cycle', 'This cycle'],
              %w[Primary 14% 53% 59% 55%],
              %w[Secondary 18% 50% 52% 44%],
              ['Art & Design', '25%', '60%', '51%', '46%'],
              %w[Biology 0% 33% 38% 32%],
              ['Design & Technology', '0%', '50%', '55%', '43%'],
              %w[English 18% 67% 48% 45%],
              %w[Geography 13% 100% 53% 43%],
              %w[History 40% 50% 59% 53%],
              %w[Mathematics 6% 50% 38% 32%],
              %w[Music 33% 100% 56% 57%],
              %w[Others 30% 31% 35% 29%],
              ['Physical Education', '46%', '67%', '66%', '53%'],
              %w[Physics 7% 33% 29% 21%],
              ['Religious Education', '40%', '50%', '43%', '35%'],
              ['All subjects', '17%', '51%', '59%', '52%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a offers_accepted report' do
          zip_file = call
          csv_filename = 'offers_accepted_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'All providers', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 7 7 0% 7115 6503 -9%],
              %w[Secondary 21 22 5% 8716 10079 16%],
              ['Art & Design', '1', '2', '100%', '304', '480', '58%'],
              ['Biology', '0', '1', 'Not available', '505', '713', '41%'],
              %w[English 2 4 100% 1326 1410 6%],
              ['Geography', '0', '2', 'Not available', '517', '515', '0%'],
              %w[History 2 2 0% 624 604 -3%],
              %w[Mathematics 1 1 0% 1091 1370 26%],
              %w[Music 1 1 0% 145 195 34%],
              %w[Others 6 4 -33% 279 262 -6%],
              ['Physical Education', '6', '4', '-33%', '1260', '1230', '-2%'],
              %w[Physics 1 1 0% 359 713 99%],
              ['Religious Education', '1', '0', '-100%', '182', '281', '54%'],
              ['All subjects', '28', '29', '4%', '16097', '16817', '4%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a deferrals report' do
          zip_file = call
          csv_filename = 'deferrals_*.csv'
          csv_data =
            [
              ['Deferrals', provider.name, 'All providers'],
              ['Deferrals this cycle to next', '0', '514'],
              ['Deferrals last cycle to this cycle', '0', '394'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a candidates_rejected report' do
          zip_file = call
          csv_filename = 'candidates_rejected_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'All providers', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 40 2 -95% 2951 2446 -17%],
              %w[Secondary 94 11 -88% 4844 5468 13%],
              ['Art & Design', '3', '0', '-100%', '181', '242', '34%'],
              %w[Biology 14 1 -93% 561 722 29%],
              %w[Chemistry 5 1 -80% 492 709 44%],
              %w[Computing 5 0 -100% 384 505 32%],
              ['Design & Technology', '2', '0', '-100%', '166', '246', '48%'],
              %w[Drama 3 0 -100% 98 98 0%],
              %w[English 12 0 -100% 927 817 -12%],
              %w[Geography 7 0 -100% 283 337 19%],
              %w[History 2 1 -50% 286 288 1%],
              %w[Mathematics 14 0 -100% 1238 1450 17%],
              ['Modern Foreign Languages', '2', '1', '-50%', '322', '451', '40%'],
              %w[Music 2 0 -100% 69 59 -14%],
              %w[Others 13 5 -62% 404 397 -2%],
              ['Physical Education', '4', '0', '-100%', '472', '716', '52%'],
              %w[Physics 11 1 -91% 518 1293 150%],
              ['Religious Education', '3', '1', '-67%', '178', '288', '62%'],
              ['All subjects', '132', '13', '-90%', '6557', '6237', '-5%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a proportion_of_candidates_who_have_waited_more_than_30_working_days_for_a_response report' do
          zip_file = call
          csv_filename = 'proportion_of_candidates_who_have_waited_more_than_30_working_days_for_a_response_*.csv'
          csv_data =
            [
              ['', provider.name, '', 'All providers', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Last cycle', 'This cycle'],
              %w[Primary 4% 7% 58% 24%],
              %w[Secondary 4% 7% 24% 34%],
              %w[Drama 95% 100% 32% 14%],
              %w[Others 9% 8% 24% 24%],
              ['All subjects', '5%', '5%', '24%', '32%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end
      end

      context 'when the region is not all of england' do
        let(:region) { :london }
        let(:report_type) { :REGIONAL }

        it 'exports a candidates_who_have_submitted_applications report for the selected region' do
          zip_file = call
          csv_filename = 'candidates_who_have_submitted_applications_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'Providers in London', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 58 15 -74% 1014 920 -9%],
              %w[Secondary 136 50 -63% 3341 4387 31%],
              ['Art & Design', '4', '5', '25%', '84', '115', '37%'],
              %w[Biology 16 3 -81% 336 216 -36%],
              %w[Chemistry 6 1 -83% 265 245 -8%],
              %w[Computing 6 0 -100% 126 192 52%],
              ['Design & Technology', '3', '2', '-33%', '37', '80', '116%'],
              %w[Drama 3 1 -67% 36 24 -33%],
              %w[English 17 6 -65% 237 270 14%],
              %w[Geography 8 2 -75% 153 107 -30%],
              %w[History 5 4 -20% 110 94 -15%],
              %w[Mathematics 17 2 -88% 549 561 2%],
              ['Modern Foreign Languages', '3', '1', '-67%', '368', '502', '36%'],
              %w[Music 3 1 -67% 26 21 -19%],
              %w[Others 23 13 -43% 18 7 -61%],
              ['Physical Education', '13', '6', '-54%', '169', '179', '6%'],
              %w[Physics 14 3 -79% 859 1787 108%],
              ['Religious Education', '5', '2', '-60%', '78', '49', '-37%'],
              ['All subjects', '192', '65', '-66%', '4319', '5252', '22%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a candidates_that_received_an_offer report for the selected region' do
          zip_file = call
          csv_filename = 'candidates_that_received_an_offer_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'Providers in London', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 8 8 0% 359 409 14%],
              %w[Secondary 25 25 0% 574 582 1%],
              ['Art & Design', '1', '3', '200%', '29', '24', '-17%'],
              ['Biology', '0', '1', 'Not available', '36', '24', '-33%'],
              ['Design & Technology', '0', '1', 'Not available', '18', '20', '11%'],
              %w[English 3 4 33% 69 81 17%],
              %w[Geography 1 2 100% 40 28 -30%],
              %w[History 2 2 0% 42 46 10%],
              %w[Mathematics 1 1 0% 84 81 -4%],
              %w[Music 1 1 0% 7 9 29%],
              %w[Others 7 4 -43% 4 4 0%],
              ['Physical Education', '6', '4', '-33%', '87', '84', '-3%'],
              %w[Physics 1 1 0% 26 35 35%],
              ['Religious Education', '2', '1', '-50%', '15', '11', '-27%'],
              ['All subjects', '33', '33', '0%', '930', '989', '6%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a proportion_of_candidates_with_an_offer report for the selected region' do
          zip_file = call
          csv_filename = 'proportion_of_candidates_with_an_offer_*.csv'
          csv_data =
            [
              ['', provider.name, '', 'Providers in London', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Last cycle', 'This cycle'],
              %w[Primary 14% 53% 35% 44%],
              %w[Secondary 18% 50% 17% 13%],
              ['Art & Design', '25%', '60%', '35%', '21%'],
              %w[Biology 0% 33% 11% 11%],
              ['Design & Technology', '0%', '50%', '49%', '25%'],
              %w[English 18% 67% 29% 30%],
              %w[Geography 13% 100% 26% 26%],
              %w[History 40% 50% 38% 49%],
              %w[Mathematics 6% 50% 15% 14%],
              %w[Music 33% 100% 27% 43%],
              %w[Others 30% 31% 22% 57%],
              ['Physical Education', '46%', '67%', '51%', '47%'],
              %w[Physics 7% 33% 3% 2%],
              ['Religious Education', '40%', '50%', '19%', '22%'],
              ['All subjects', '17%', '51%', '22%', '19%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a offers_accepted report for the selected region' do
          zip_file = call
          csv_filename = 'offers_accepted_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'Providers in London', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 7 7 0% 266 323 21%],
              %w[Secondary 21 22 5% 424 445 5%],
              ['Art & Design', '1', '2', '100%', '27', '20', '-26%'],
              ['Biology', '0', '1', 'Not available', '24', '12', '-50%'],
              %w[English 2 4 100% 48 53 10%],
              ['Geography', '0', '2', 'Not available', '32', '23', '-28%'],
              %w[History 2 2 0% 28 35 25%],
              %w[Mathematics 1 1 0% 65 69 6%],
              %w[Music 1 1 0% 4 8 100%],
              %w[Others 6 4 -33% 3 3 0%],
              ['Physical Education', '6', '4', '-33%', '66', '62', '-6%'],
              %w[Physics 1 1 0% 23 30 30%],
              ['Religious Education', '1', '0', '-100%', '11', '8', '-27%'],
              ['All subjects', '28', '29', '4%', '691', '770', '11%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a deferrals report for the selected region' do
          zip_file = call
          csv_filename = 'deferrals_*.csv'
          csv_data =
            [
              ['Deferrals', provider.name, 'Providers in London'],
              ['Deferrals this cycle to next', '0', '42'],
              ['Deferrals last cycle to this cycle', '0', '22'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a candidates_rejected report for the selected region' do
          zip_file = call
          csv_filename = 'candidates_rejected_*.csv'
          csv_data =
            [
              ['', provider.name, '', '', 'Providers in London', '', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change'],
              %w[Primary 40 2 -95% 168 211 26%],
              %w[Secondary 94 11 -88% 1103 1996 81%],
              ['Art & Design', '3', '0', '-100%', '14', '35', '150%'],
              %w[Biology 14 1 -93% 137 130 -5%],
              %w[Chemistry 5 1 -80% 105 152 45%],
              %w[Computing 5 0 -100% 54 25 -54%],
              ['Design & Technology', '2', '0', '-100%', '6', '16', '167%'],
              %w[Drama 3 0 -100% 10 2 -80%],
              %w[English 12 0 -100% 72 80 11%],
              %w[Geography 7 0 -100% 41 30 -27%],
              %w[History 2 1 -50% 10 11 10%],
              %w[Mathematics 14 0 -100% 230 156 -32%],
              ['Modern Foreign Languages', '2', '1', '-50%', '114', '219', '92%'],
              %w[Music 2 0 -100% 5 3 -40%],
              %w[Others 13 5 -62% 4 1 -75%],
              ['Physical Education', '4', '0', '-100%', '21', '26', '24%'],
              %w[Physics 11 1 -91% 307 1177 283%],
              ['Religious Education', '3', '1', '-67%', '27', '15', '-44%'],
              ['All subjects', '132', '13', '-90%', '1250', '2175', '74%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end

        it 'exports a proportion_of_candidates_who_have_waited_more_than_30_working_days_for_a_response report for the selected region' do
          zip_file = call
          csv_filename = 'proportion_of_candidates_who_have_waited_more_than_30_working_days_for_a_response_*.csv'
          csv_data =
            [
              ['', provider.name, '', 'Providers in London', ''],
              ['Subject', 'Last cycle', 'This cycle', 'Last cycle', 'This cycle'],
              %w[Primary 4% 7% 13% 7%],
              %w[Secondary 4% 7% 12% 20%],
              %w[Drama 95% 100% 6% 4%],
              %w[Others 9% 8% 0% 14%],
              ['All subjects', '5%', '5%', '12%', '18%'],
            ]

          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end
      end
    end
  end
end
