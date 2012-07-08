require 'date'

class OKCupid

  INBOX_URL = "/messages"
  OUTBOX_URL = "/messages?folder=2"

  def inbox
    @inbox ||= Mailbox.new(INBOX_URL, @browser)
  end

  def outbox
    @outbox ||= Mailbox.new(OUTBOX_URL, @browser)
  end
  
  def conversation_for(id)
    Mailbox::Conversation.by_id(id, @browser)
  end
  
  class Mailbox
    class MessageSnippet
      
      attr_accessor :profile_username, :profile_small_avatar_url, :preview, :last_date, :conversation_url
      
      def self.from_html(html)
        profile_username = html.search('a.subject').text
        preview = html.search('.previewline').text
        last_date = html.search('.timestamp').text
        conversation_url = html.search('p:first').attribute('onclick').text.gsub('window.location=\'', '').gsub('\';','')
        profile_small_avatar_url = html.search('a.photo img').attribute('src').text
        
        self.new({
          profile_username: profile_username,
          preview: preview,
          last_date: Date.parse(last_date),
          conversation_url: conversation_url,
          profile_small_avatar_url: profile_small_avatar_url
        })
      end
      
      def initialize(attrs)
        attrs.each do |attr, value|
          self.send("#{attr}=", value)
        end
      end
    end
    
    class Conversation
      attr_accessor :from_profile_username, :messages
      
      def self.by_id(id, browser)
        html = browser.get("/messages?readmsg=true&threadid=#{id}&folder=1")
        from_profile_username = html.search('li.to_me:first a').attribute('title').text
         
        messages = []
        
        html.search('#thread  > li').each do |message_html|
          css_class = message_html.attribute('class')
          css_id    = message_html.attribute('id')
          
          # matches 'from_me' and 'to_me' classes.
          if (css_class && css_class.text.match(/_me/))
            if(css_id && css_id.text == 'compose')
              next
            else
              messages << Message.from_html(message_html)
            end
          else
            next
          end
        end
        
        self.new({
          from_profile_username: from_profile_username,
          messages: messages
        })
      end
      
      def initialize(attrs)
        attrs.each do |attr, value|
          self.send("#{attr}=", value)
        end
      end
    end
    
    class Message
      attr_accessor :to_me, :from_me, :body
      
      def self.from_html(html)
        to_me = !!html.attribute('class').text.match(/to_me/)
        from_me = !to_me
        # time = html.search('.timestamp').text
        body = html.search('.message_body').text.gsub('<br>', "\n")
        
        self.new({
          to_me: to_me,
          from_me: from_me,
          # time: time,
          body: body
        })
      end
      
      def initialize(attrs)
        attrs.each do |attr, value|
          self.send("#{attr}=", value)
        end
      end
    end
    
    attr_reader :url

    def initialize(url, browser)
      @browser = browser
      @url = url
    end
    
    def useage
      html = @browser.get(@url)
      current, max = html.search('p.fullness').text.match(/([\d]+) of ([\d]+)/).captures
      
      return { current: current.to_i, max: max.to_i }
    end
    
    def messages
      @messages = []
      
      html = @browser.get(@url)
      messages_html = html.search('#messages li')
      @messages += messages_html.collect do |message|
        MessageSnippet.from_html(message)
      end
      
      @messages
    end
  end
end