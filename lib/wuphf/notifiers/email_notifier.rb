# frozen_string_literal: true

require "net/smtp"

module Wuphf
  module Notifiers
    class EmailNotifier
      UnsupportedProviderError = Class.new(StandardError)

      class ConfigurationBuilder
        def self.build_from(configuration)
          case configuration.smtp_provider
          when :gmail
            GmailConfiguration
          when :custom
            DefaultConfiguration
          else
            raise UnsupportedProviderError
          end.new(**configuration.to_h)
        end
      end

      DefaultConfiguration = Struct.new(
        :username,
        :password,
        :smtp_provider,
        :smtp_server,
        :smtp_port,
        :mail_from_domain,
        keyword_init: true,
      )

      class GmailConfiguration < DefaultConfiguration
        def smtp_server
          "smtp.gmail.com"
        end

        def mail_from_domain
          "gmail.com"
        end

        def smtp_port
          587
        end
      end

      MissingOptionError = Class.new(ArgumentError)
      SendMailError = Class.new(StandardError)

      attr_reader(:configuration)

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
        smtp.open_timeout = 5
        smtp.read_timeout = 5

        smtp.start(configuration.mail_from_domain, configuration.username, configuration.password, :login) do
          result = smtp.send_message(msg, from_email, to_email)

          if Wuphf.configuration.debug_mode?
            Wuphf.configuration.logger.debug("Mail result: #{result.inspect}")
            Wuphf.configuration.logger.debug("Mail sent")
          end
        end

        true
      rescue => err
        raise SendMailError, "error establishing smtp connection. msg: #{err.message}"
      end
    end
  end
end
