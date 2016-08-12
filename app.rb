require 'sinatra/base'

require 'slack-ruby-client'
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

module SecToSlack
  SEC_LISTS = (
    ['rubyonrails-security@googlegroups.com'] + (ENV['SEC_LISTS'] || [])
  ).freeze

  class Application < Sinatra::Base
    get '/' do
      'Hello World'
    end

    post '/' do
      EmailProcessor.new(params).run
      status 200
    end
  end

  class EmailProcessor
    def initialize(email)
      @email = email
    end

    def run
      puts "Email received from #{@email['From']}"
      puts "Email body: #{@email["body-plain"]}"

      lists = (SEC_LISTS & @email['To'].split(', '))
      return unless lists.any?

      @notifier_params = {}
      @notifier_params['lists'] = lists
      @notifier_params['subject'] = @email['subject']

      Notifier.new(@notifier_params).run
    end
  end

  class Notifier
    def initialize(params)
      @params = params
    end

    def run
      client = Slack::Web::Client.new
      attachments = []

      @params['lists'].each do |list|
        title_link = ''

        # Set title_link to the URL for the security google group
        list_name = list.split('@googlegroups.com')
        if list_name != [list]
          title_link = "https://groups.google.com/forum/#!forum/#{list_name}"
        end

        a = {
          fallback: "New email sent to #{list} - #{@params['subject']}",
          title: "New email sent to '#{list}'",
          title_link: title_link,
          text: @params['subject'],
          color: "#cb5234"
        }

        attachments << a
      end

      client.chat_postMessage({
        channel: ENV['SLACK_ANN_CHANNEL'],
        text: ':sirens: New CVEs have been released! Please start upgrading dependencies.',
        as_user: true,
        attachments: attachments
      })
    end
  end
end
