[VoodooSMS](http://www.voodoosms.com/) API
===============

Supports Voodoo's API v2.1

- [RubyGems](https://rubygems.org/gems/voodoo_sms)

`gem install voodoo_sms`

## Example usage

    client = VoodooSMS.new('username', 'password')
    # => #<VoodooSMS:0x007f96dc947170 @params={:query=>{:uid=>"username", :pass=>"password"}}>

    client.get_credit
    # => "15.0000"

    client.send_sms('SenderID', '440000000000', 'Message')
    # => "5143598"

    client.get_dlr_status('5143598')
    # => "Delivered"

    messages = client.get_sms(Date.new(2014,10,17), Date.new(2014,10,17))
    # => [#<OpenStruct from="447000000006", timestamp=#<DateTime: 2014-10-17T15:32:58+00:00>, message="Inbound message body">]
