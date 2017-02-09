require 'spec_helper'

describe Skycore::PayloadBuilder do
  let (:api_key) { "my_key" }
  let (:builder) { Skycore::PayloadBuilder.new(api_key) }

  describe '#build_save_mms' do
    it "has correct api_key" do
      payload = builder.build_save_mms("Subject", "Body", "Fallback", [])
      parsed = Crack::XML.parse(payload)
      expect(parsed["REQUEST"]["API_KEY"]).to eq(api_key)
    end

    it "includes fallback text" do
      payload = builder.build_save_mms("Subject", "Body", "Fallback", [])
      parsed = Crack::XML.parse(payload)
      expect(parsed["REQUEST"]["FALLBACKSMSTEXT"]).to eq("Fallback")
    end

    it "builds simple text" do
      payload = builder.build_save_mms("Subject", "Body", "Fallback", [])
      parsed = Crack::XML.parse(payload)
      slide = parsed["REQUEST"]["SLIDE"]
      expect(slide.keys.size).to eq(1)
      expect(slide["TEXT"]).to eq("Body")
    end

    it "builds text + image" do
      image_url = "https://news.ycombinator.com/y18.gif"
      payload = builder.build_save_mms("Subject", "Body", "Fallback", [
        {
          type: "IMAGE",
          url: image_url
        }
      ])
      parsed = Crack::XML.parse(payload)
      slide = parsed["REQUEST"]["SLIDE"]
      expect(slide.keys.size).to eq(2)
      expect(slide["TEXT"]).to eq("Body")
      expect(slide["IMAGE"]["URL"]).to eq(image_url)
    end
  end

  context "#build_send_saved_mms" do
    let (:from) { "41044" }
    let (:to) { "12062999999" }
    let (:parsed) {
      payload = builder.build_send_saved_mms(from, to, 123, "fallback", 4,
                                             "NEWSUBJECT")
      Crack::XML.parse(payload)
    }

    it "builds correct api key" do
      expect(parsed["REQUEST"]["API_KEY"]).to eq(api_key)
    end

    it "builds correct TO field" do
      expect(parsed["REQUEST"]["TO"]).to eq(to)
    end

    it "builds correct FALLBACKSMSTEXT field" do
      expect(parsed["REQUEST"]["FALLBACKSMSTEXT"]).to eq("fallback")
    end

    it "builds correct FROM field" do
      expect(parsed["REQUEST"]["FROM"]).to eq(from)
    end

    it "builds correct OPERATORID field" do
      expect(parsed["REQUEST"]["OPERATORID"]).to eq("4")
    end

    it "builds correct CUSTOMSUBJECT field" do
      expect(parsed["REQUEST"]["CUSTOMSUBJECT"]).to eq("NEWSUBJECT")
    end
  end
end
