# frozen_string_literal: true

require "logger"
require_relative "notifiers/email_notifier"

module Wuphf
  class Configuration
    attr_accessor(:notifiers, :logger, :debug)
    attr_writer(:debug_mode)

    InvalidConfigurationError = Class.new(StandardError)

    def initialize
      @notifiers = {}
      @logger = Logger.new($stdout)
    end

    def debug_mode?
      !!@debug_mode
    end

    def register_notifier(notifier)
      notifier = notifier.to_sym

      if notifiers.keys.include?(notifier)
        raise InvalidConfigurationError, "#{notifier} has already been registered."
      end

      case notifier
      when :email
        if debug_mode?
          logger.info("Registering #{notifier} notifier")
        end

        config = Notifiers::EmailNotifier::Configuration.new

        yield(config)

        @notifiers[notifier] = Notifiers::EmailNotifier.new(config)
      else
        raise InvalidConfigurationError, "#{notifier} is not a valid notifier."
      end

      true
    end
  end
end
