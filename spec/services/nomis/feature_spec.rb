require 'rails_helper'

RSpec.describe Nomis::Feature do
  subject { described_class }

  let(:prison_name) { 'Pentonville' }

  describe 'when the api is disabled' do
    before do
      switch_off_api
    end

    it { is_expected.not_to be_contact_list_enabled(anything) }
    it { expect(described_class.contact_list_enabled?(anything)).to eq(false) }
    it { expect(described_class.prisoner_availability_enabled?).to eq(false) }
    it { expect(described_class.slot_availability_enabled?(anything)).to eq(false) }
  end

  describe 'when the api is enabled' do
    it { expect(described_class).not_to be_offender_restrictions_enabled }

    context 'with the prisoner check enabled' do
      before do
        switch_on :nomis_staff_prisoner_check_enabled
      end

      context 'with the offender restrictions enabled' do
        before do
          switch_on :nomis_staff_offender_restrictions_enabled
        end

        it { expect(described_class).to be_offender_restrictions_enabled }
      end

      context 'with the offender restrictions disabled' do
        before do
          switch_off :nomis_staff_offender_restrictions_enabled
        end

        it { expect(described_class).not_to be_offender_restrictions_enabled }
      end
    end

    describe '.contact_list_enabled?' do
      context  'when disabled for a given prison' do
        before { switch_feature_flag_with(:staff_prisons_without_nomis_contact_list, [prison_name]) }

        it { is_expected.not_to be_contact_list_enabled prison_name }
      end

      context 'when enabled for a given prison' do
        before { switch_feature_flag_with(:staff_prisons_without_nomis_contact_list, []) }

        it { is_expected.to be_contact_list_enabled prison_name }
      end
    end

    describe '.prisoner_availability_enabled?' do
      context 'when the prisoner availability is disabled' do
        before do
          switch_off :nomis_staff_prisoner_availability_enabled
        end

        it { expect(described_class.prisoner_availability_enabled?).to eq(false) }
      end

      context 'when the prisoner availability enabled' do
        before do
          switch_on :nomis_staff_prisoner_availability_enabled
        end

        it { expect(described_class.prisoner_availability_enabled?).to eq(true) }
      end
    end
  end

  describe '.slot_availability_enabled?' do
    context 'when the slot availability flag is disabled' do
      before do
        switch_off :nomis_staff_slot_availability_enabled
      end

      it { expect(described_class.slot_availability_enabled?(anything)).to eq(false) }
    end

    context 'when the slot availability flag is enabled and the visit prison is not on the list' do
      before do
        switch_on :nomis_staff_slot_availability_enabled
        switch_feature_flag_with(:staff_prisons_with_slot_availability, [])
      end

      it { expect(described_class.slot_availability_enabled?(prison_name)).to eq(false) }
    end

    context 'when the slot availability flag is enabled and the visit prison is not on the list' do
      before do
        switch_on :nomis_staff_slot_availability_enabled
        switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison_name])
      end

      it { expect(described_class.slot_availability_enabled?(prison_name)).to eq(true) }
    end
  end

  describe '.book_to_nomis_enabled?' do
    context 'when the book to nomis flag is disabled' do
      before do
        switch_off :nomis_staff_book_to_nomis_enabled
      end

      it { expect(described_class.book_to_nomis_enabled?(anything)).to eq(false) }
    end

    context 'when the book to nomis flag is enabled' do
      before do
        switch_on :nomis_staff_book_to_nomis_enabled
      end

      context 'the visit prison is not on the list' do
        before do
          switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [])
        end

        it { expect(described_class.book_to_nomis_enabled?(prison_name)).to eq(false) }
      end

      context 'the visit prison is on the list' do
        before do
          switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison_name])
        end

        it { expect(described_class.book_to_nomis_enabled?(prison_name)).to eq(true) }
      end
    end
  end
end
