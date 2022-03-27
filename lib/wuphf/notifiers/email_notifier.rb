# frozen_string_literal: true

require "net/smtp"

module Wuphf
  module Notifiers
    class EmailNotifier
      Configuration = Struct.new(
        :smtp_server,
        :smtp_port,
        :mail_from_domain,
        :username,
        :password,
        keyword_init: true
      )

      attr_reader(:configuration)

      MissingOptionError = Class.new(ArgumentError)

      def initialize(configuration)
        @configuration = configuration
      end

      def notify(subject:, body:, from_email:, to_email:)
        raise MissingOptionError, "subject is required" if subject.nil?
        raise MissingOptionError, "body is required" if body.nil?
        raise MissingOptionError, "from_email is required" if from_email.nil?
        raise MissingOptionError, "to_email is required" if to_email.nil?

        if Wuphf.configuration.debug_mode?
          Wuphf.configuration.logger.debug("Setting up SMTP connection.")
          Wuphf.configuration.logger.debug("Attempting to send mail.")
        end

        msg = "Subject: #{subject}\n\n#{body}"
        smtp = Net::SMTP.new(configuration.smtp_server, configuration.smtp_port)
        smtp.enable_starttls
        smtp.start(configuration.mail_from_domain, configuration.username, configuration.password, :login) do
          smtp.send_message(msg, from_email, to_email)
        end

        if Wuphf.configuration.debug_mode?
          Wuphf.configuration.logger.debug("Mail sent")
        end
      end
    end
  end
end
