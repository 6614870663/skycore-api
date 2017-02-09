# Skycore

Skycore API wrapper gem


## Installation


```ruby
gem 'skycore'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install skycore

## Usage

```ruby
    api_key = 'changeme'
    skycore = Skycore.new(api_key, '41044', true)
    subject = "Hello"
    mms_body = "bdgr" * 1000 + "\n\n Catch that?"
    fallback = "SMS fallback"

    # Save MMS on Skycore server and grab MMSID
    res = skycore.save_mms(subject, mms_body, fallback, [{
        type: "IMAGE", url: "https://news.ycombinator.com/y18.gif"
    }])
    mmsid = res['MMSID']

    # Send saved message, optionally overriding some things
    res = skycore.send_saved_mms("1206334444", mmsid, text)
```

Take a look at `lib/skycore.rb` to find out what gem API looks like

