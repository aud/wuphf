# frozen_string_literal: true

require_relative "notifiers/email_notifier"
require_relative "notifiers/twilio_sms_notifier"

module Wuphf
  class RegistrationManager
    attr_accessor(:notifiers)

    InvalidConfigurationError = Class.new(StandardError)

    def initialize
      @notifiers = {}
    end

    def register_notifier(notifier)
      notifier = notifier.to_sym

      if notifiers.keys.include?(notifier)
        raise InvalidConfigurationError, "#{notifier} has already been registered."
      end

      if Wuphf.configuration.debug_mode?
        logger.info("Registering #{notifier} notifier")
      end

      case notifier
      when :email
        config_container = OpenStruct.new

        yield(config_container)

        @notifiers[notifier] = Notifiers::EmailNotifier.new(
          Notifiers::EmailNotifier::ConfigurationBuilder.build_from(config_container),
        )
      when :twilio_sms
        config = Notifiers::TwilioSmsNotifier::Configuration.new

        yield(config)

        @notifiers[notifier] = Notifiers::TwilioSmsNotifier.new(config)
      else
        raise InvalidConfigurationError, "#{notifier} is not a valid notifier."
      end

      true
    end
  end
end
