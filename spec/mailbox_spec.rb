require 'spec_helper'

describe "Mailbox" do
  it "tells you how full your mailbox is" do
    VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
      okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
      @inbox = okc.inbox
      @inbox.useage.should == {
        current: 233,
        max: 300
      }
    end
  end
  
  it "can access the first message, up to 30" do
    VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
      okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
      @inbox = okc.inbox
      @inbox.messages.count.should == 30
    end
  end
  
  it "each message header is a header" do
    VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
      okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
      @inbox = okc.inbox
      @inbox.messages.all? {|m| m.is_a?(OKCupid::Mailbox::MessageSnippet)}.should == true
    end
  end

  describe "inbox object" do

    before(:each) do
      VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
        @okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
        @inbox = @okc.inbox
      end
    end

    it "uses the inbox url" do
      @inbox.url.should == OKCupid::INBOX_URL
    end

    it "is cached" do
      new_inbox = @okc.inbox
      @inbox.object_id.should == new_inbox.object_id
    end

    it "includes unsolicited messages" do
      pending "cassettes are re-recorded"
      VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
        @outbox.messages.map(&:profile_username).should include("incoming_username")
      end
    end

  end

  describe "outbox object" do

    before(:each) do
      VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
        @okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
        @outbox = @okc.outbox
      end
    end

    it "uses the outbox url" do
      @outbox.url.should == OKCupid::OUTBOX_URL
    end

    it "is cached" do
      new_outbox = @okc.outbox
      @outbox.object_id.should == new_outbox.object_id
    end

    it "includes messages with no response" do
      pending "cassettes are re-recorded"
      VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
        @outbox.messages.map(&:profile_username).should include("outgoing_username")
      end
    end

  end

end

describe "Conversation" do
  before(:each) do
    VCR.use_cassette('loading_conversation') do
      okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
      @conversation = okc.conversation_for('5887692615523576083')
    end
  end
  
  it "has a from_profile_username" do
    @conversation.from_profile_username.should == 'snowpea383'
  end
  
  it "contains a list of messages" do
    @conversation.messages.count.should == 12
  end
  
  describe "each message" do
    before(:each) do
      @message = @conversation.messages.last
    end
    
    it "has a to_me" do
      @message.to_me.should == false
    end
    
    it "has a from_me" do
      @message.from_me.should == true
    end
  end
end

describe "MessageSnippet" do
  before(:each) do
    VCR.use_cassette('loading_mailbox', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
      okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])
      inbox = okc.inbox
      @header = inbox.messages.first
    end
  end
  
  it "has a profile_username" do
    @header.profile_username.should == 'teachforall'
  end
  
  it "has a profile_small_avatar_url" do
    @header.profile_small_avatar_url.should == 'http://ak2.okccdn.com/php/load_okc_image.php/images/60x60/60x60/0x30/198x228/2/18256810077890846020.jpeg'
  end
  
  it "has a preview" do
    @header.preview.should == 'No, I was there like a month ago. I live in EL so  ...'
  end
  
  it "has a conversation_url" do
    @header.conversation_url.should == '/messages?readmsg=true&threadid=9950201897626358080&folder=1'
  end
  
  it "has a last_date" do
    @header.last_date.should == Date.new(2012, 03, 25)
  end
end