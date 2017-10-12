require "rails_helper"

RSpec.describe CancelNomisVisit do
  let(:visit)  { create(:booked_visit, nomis_id: 1234) }

  subject { described_class.new(visit) }

  before do
    visit.build_cancellation(
      reasons: Cancellation::PRISONER_RELEASED,
      nomis_cancelled: true
    )
  end
  describe '#execute' do
    context 'successful cancellation' do
      let(:params) { { comment: 'A cancellation message' } }
      let(:nomis_cancellation) do
        Nomis::Cancellation.new('message' => 'Visit cancelled')
      end

      it 'has cancelled the visit' do
        expect(Nomis::Api.instance).
          to receive(:cancel_visit).
               with(
                 visit.prisoner.nomis_offender_id,
                 visit.nomis_id,
                 params: params
               ).and_return(nomis_cancellation)

        expect(subject.execute(params)).to be_success
      end
    end

    context 'unsucessfully cancellation' do
      context 'with an unexpected error' do
        before do
          simulate_api_error_for :cancel_visit
        end

        it 'a nomis API error' do
          expect(subject.execute).to have_attributes(message: BookingResponse::NOMIS_API_ERROR)
        end
      end

      context 'with an expected error message' do
        let(:cancellation) do
          Nomis::Cancellation.new('error' => { 'message' => error_message })
        end

        before { mock_nomis_with :cancel_visit, cancellation }

        context 'when the visit is not found' do
          let(:error_message) { 'Visit not found' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::VISIT_NOT_FOUND)
          end
        end

        context 'when the visit has already been cancelled' do
          let(:error_message) { 'Visit already cancelled' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::VISIT_ALREADY_CANCELLED)
          end
        end

        context 'when the visit has already been completed' do
          let(:error_message) { 'Visit completed' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::VISIT_COMPLETED)
          end
        end

        context 'when the cancellation code is invalid' do
          let(:error_message) { 'Invalid or missing visit_id' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::INVALID_CANCELLATION_CODE)
          end
        end
      end
    end
  end
end
