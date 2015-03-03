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

  describe :get_credit do
    context '200 success', vcr: :success  do
      let(:vcr_cassette) { 'get_credit' }
      it { expect(client.get_credit).to eq '123.0000' }
    end
    context 'Voodoo has changed response json, credit is renamed to credit_remaining', vcr: :success  do
      let(:vcr_cassette) { 'get_credit_changed_response' }
      it { expect { expect(client.get_credit) }.to raise_error VoodooSMS::Error::Unexpected }
    end
  end

  describe :send_sms do
    let(:orig) {'SENDERID'}
    let(:dest) {'447123456789'}
    let(:msg) {'Test message'}

    context '200 success', vcr: :success do
      let(:vcr_cassette) { 'send_sms' }
      it { expect(client.send_sms(orig, dest, msg)).to eq("4103395") }
    end

    context '200 success - multipart message', vcr: :success do
      let(:vcr_cassette) { 'send_multipart_sms' }
      it { expect(client.send_sms(orig, dest, 'A'*320)).to eq("4103395") }
    end

    context 'Voodoo has changed response json, reference_id is renamed to message_id', vcr: :success do
      let(:vcr_cassette) { 'send_sms_response_changed' }
      it { expect { client.send_sms(orig, dest, msg) }.to raise_error VoodooSMS::Error::Unexpected }
    end

    context 'validation' do
      before(:each) do
        response = double("HTTParty::Response",
          parsed_response: {"result" => 200, "resultText" => "200 OK", "reference_id" => "4103395"})
        allow(response).to receive(:[]).with("result").and_return("200 OK")
        allow(VoodooSMS).to receive(:get).and_return(response)
      end

      context 'originator parameter' do
        it 'allows a maximum of 15 numeric digits' do
          expect{client.send_sms('0'*15, dest, msg)}.to_not raise_error
        end

        it 'allows a maximum of 11 alphanumerics' do
          expect{client.send_sms("#{'0A'*5}0", dest, msg)}.to_not raise_error
        end

        it 'does not allow nil entries' do
          expect{client.send_sms(nil, dest, msg)}.to raise_error VoodooSMS::Error::RequiredParameter
        end

        it 'does not allow blank entry' do
          expect{client.send_sms('', dest, msg)}.to raise_error VoodooSMS::Error::RequiredParameter
        end

        it 'does not allow input longer than 15 numerics digits' do
          expect{client.send_sms('0'*16, dest, msg)}.to raise_error VoodooSMS::Error::InvalidParameterFormat
        end

        it 'does not allow input longer than 11 alphanumerics' do
          expect{client.send_sms('0A'*6, dest, msg)}.to raise_error VoodooSMS::Error::InvalidParameterFormat
        end
      end

      context 'destination parameter' do
        it 'allows a maximum of 10 numeric digits' do
          expect{client.send_sms(orig, '0'*10, msg)}.to_not raise_error
        end

        it 'allows a maximum of 15 numeric digits' do
          expect{client.send_sms(orig, '0'*15, msg)}.to_not raise_error
        end

        it 'does not allow nil entries' do
          expect{client.send_sms(orig, nil, msg)}.to raise_error VoodooSMS::Error::RequiredParameter
        end

        it 'does not allow blank entry' do
          expect{client.send_sms(orig, '', msg)}.to raise_error VoodooSMS::Error::RequiredParameter
        end

        it 'does not allow invalid E.164 formats' do
          expect{client.send_sms(orig, 'ABC', msg)}.to raise_error VoodooSMS::Error::InvalidParameterFormat
        end
      end
    end
  end

  describe :get_sms do
    context '200 success', vcr: :success do
      describe 'without a keyword' do
        let(:vcr_cassette) { 'get_sms' }
        it 'returns an array of messages' do
          response = client.get_sms(DateTime.new(2014,10,10,12,0,0),
                                    DateTime.new(2014,10,17,12,0,0))
          expect(response.count).to eq 2
          expect(response.first.message).to eq 'SMS Body'
          expect(response.first.timestamp).to be_a DateTime
          expect(response.first.from).to eq '447000000002'
        end
      end

      describe 'with a keyword' do
        let(:vcr_cassette) { 'get_sms_with_keyword' }
        it 'returns an array of messages' do
          response = client.get_sms(DateTime.new(2014,10,10),
                                    DateTime.new(2014,10,17),
                                    'TEMP')
          expect(response.count).to eq 2
          expect(response.first.message).to eq 'TEMP'
          expect(response.first.timestamp).to be_a DateTime
          expect(response.first.from).to eq '447000000002'
        end
      end

      describe 'no messages returned' do
        let(:vcr_cassette) { 'get_sms_empty' }
        it 'returns an array of messages' do
          expect(client.get_sms(DateTime.new(2014,10,17,12,0,0),
            DateTime.new(2014,10,10,12,0,0))).to eq []
        end
      end
    end
  end

  describe :get_dlr_status do
    context '200 success', vcr: :success  do
      let(:vcr_cassette) { 'get_dlr_status' }
      it { expect(client.get_dlr_status('5143598')).to eq 'Delivered' }
    end
    context 'Voodoo has changed response json, reference_id is renamed to message_id', vcr: :success do
      let(:vcr_cassette) { 'get_dlr_status_response_changed' }
      it { expect { client.get_dlr_status('5143598') }.to raise_error VoodooSMS::Error::Unexpected }
    end
  end

  xdescribe :transfer_credit do
  end
end
