require 'spec_helper'

describe VoodooSMS do
  let(:client) { VoodooSMS.new('username', 'password') }

  describe 'errors' do
    context '400 bad request', vcr: :errors do
      let(:vcr_cassette) { '400_bad_request' }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::BadRequest }
    end

    context '401 unauthorised', vcr: :errors do
      let(:vcr_cassette) { '401_unauthorised' }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::Unauthorised }
    end

    context '402 not enough credit', vcr: :errors do
      let(:vcr_cassette) { '402_not_enough_credit' }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::NotEnoughCredit }
    end

    context '403 forbidden', vcr: :errors do
      let(:vcr_cassette) { '403_forbidden' }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::Forbidden }
    end

    context '513 message too large', vcr: :errors do
      let(:vcr_cassette) { '513_message_too_large' }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::MessageTooLarge }
    end

    context 'an unknown status code', vcr: :errors do
      let(:vcr_cassette) { 'XXX_unknown' }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::Unexpected }
    end

    context 'unknown error' do
      before { allow(VoodooSMS).to receive(:get).and_raise(StandardError.new) }
      it { expect{client.get_credit}.to raise_error VoodooSMS::Error::Unexpected }
    end
  end
end
