# frozen_string_literal: true

require "twilio-ruby"

module Wuphf
  module Notifiers
    class TwilioSmsNotifier
      Configuration = Struct.new(
        :account_sid,
        :auth_token,
        keyword_init: true,
      )

      MissingOptionError = Class.new(ArgumentError)

      attr_reader(:configuration)

      def initialize(configuration)
        @configuration = configuration
      end

      def notify(from_number:, to_number:, body:)
        raise MissingOptionError, "from_number" if from_number.nil?
        raise MissingOptionError, "to_number" if to_number.nil?
        raise MissingOptionError, "body" if body.nil?

        begin
          twilio_client.messages.create(
            from: from_number,
            to: to_number,
            body: body,
          )
        rescue => err
          raise SendTwilioSmsError, "error sending sms. err: #{err.inspect}"
        end

        true
      end

      private

      def twilio_client
        @twilio_client ||= Twilio::REST::Client.new(
          configuration.account_sid,
          configuration.auth_token,
        )
      end
    end
  end
end
