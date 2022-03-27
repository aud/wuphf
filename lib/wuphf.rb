# frozen_string_literal: true

require_relative "wuphf/configuration"
require_relative "wuphf/notifiers/email_notifier"
require_relative "wuphf/version"

module Wuphf
  class << self
    UnknownNotifierError = Class.new(StandardError)

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def notify(notifier, **opts)
      notifier = notifier.to_sym

      raise UnknownNotifierError, "#{notifier.inspect} is not a registered notifier." unless notifier

      configuration.notifiers[notifier].notify(**opts)
    end
  end
end
