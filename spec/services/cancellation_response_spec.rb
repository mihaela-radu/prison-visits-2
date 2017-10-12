require 'rails_helper'

RSpec.describe CancellationResponse do
  subject(:instance) do
    described_class.new(visit, reasons: reasons)
  end

  let(:reasons) { [Cancellation::VISITOR_CANCELLED] }
  let(:visit)   { create(:booked_visit) }

  describe 'valid?' do
    describe 'with a reason' do
      it { is_expected.to be_valid }
    end

    describe 'without a reason' do
      let(:reasons) { [] }

      before do
        is_expected.not_to be_valid
      end

      it 'has an error message' do
        expect(subject.error_message).to eq('Please provide a cancellation reason')
      end
    end
  end

  describe '#cancel!' do
    let(:responder) { spy(BookingResponder::Cancel) }
    let(:mail) { double('mail', deliver_later: nil) }

    before do
      expect(BookingResponder::Cancel).to receive(:new).and_return(responder)
      allow(VisitorMailer).to receive(:cancelled).with(visit).and_return(mail)

      instance.cancel!
    end

    it 'process the cancellation' do
      expect(responder).to have_received(:process_request)
    end

    it 'enqueues the email' do
      expect(VisitorMailer).to have_received(:cancelled).with(visit)
      expect(mail).to have_received(:deliver_later)
    end
  end
end
