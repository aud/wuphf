# frozen_string_literal: true

require "logger"
require "forwardable"
require_relative "registration_manager"

module Wuphf
  class Configuration
    extend(Forwardable)

    attr_accessor(:logger)
    attr_writer(:debug_mode)
    attr_reader(:registration_manager)

    def_delegators(:@registration_manager, :register_notifier)

    def initialize
      @logger = Logger.new($stdout)
      @registration_manager = Wuphf::RegistrationManager.new
    end

    def debug_mode?
      !!@debug_mode
    end
  end
end
