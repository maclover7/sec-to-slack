require 'sinatra/base'

module SecToSlack
  SEC_LISTS = [
    'postmaster@jonathanmoss.me',
    'rubyonrails-security@googlegroups.com'
  ].freeze

  class Application < Sinatra::Base
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
      lists = (SEC_LISTS & @email['To'].split(', '))
      return unless lists

      #@notifier_params = {}
      #@notifier_params['lists'] = lists
      #@notifier_params['subject'] = @email['subject']
    end
  end
end
