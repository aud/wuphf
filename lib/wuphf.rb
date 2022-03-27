# frozen_string_literal: true

require_relative "wuphf/configuration"
require_relative "wuphf/notifiers/email_notifier"
require_relative "wuphf/version"

module Wuphf
  UnknownNotifierError = Class.new(StandardError)

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      if defined?(@configuration)
        @configuration = Configuration.new
      end
    end

    def configure
      yield(configuration)
    end

    def notify(notifier, opts = {})
      notifier = notifier.to_sym

      raise(
        UnknownNotifierError,
        "#{notifier.inspect} is not a registered notifier."
      ) unless klass = configuration.notifiers[notifier]

      klass.notify(**opts)
    end
  end
end
