# frozen_string_literal: true

require "test_helper"

class WuphfTest < Minitest::Test
  def teardown
    Wuphf.reset_configuration!
  end

  def test_that_it_has_a_version_number
    refute_nil(Wuphf::VERSION)
  end

  def test_configuration
    fake_logger = Logger.new(StringIO.new)

    Wuphf.configure do |config|
      config.register_notifier(:email) do |email|
        email.smtp_server = "smtp.gmail.com"
        email.smtp_port = 587
        email.mail_from_domain = "gmail.com"
        email.username = "email@example.com"
        email.password = "hunter2"
      end

      config.logger = fake_logger
      config.debug_mode = true
    end

    assert(Wuphf.configuration.debug_mode?)
  end

  def test_notify_with_no_registered_notifiers
    assert_raises(Wuphf::UnknownNotifierError) do
      Wuphf.notify(:test)
    end
  end

  def test_notify_with_email_and_unsupported_provider
    assert_raises(Wuphf::Notifiers::EmailNotifier::Configuration::UnsupportedProviderError) do
      Wuphf.configure do |config|
        config.register_notifier(:email) do |email|
          # email.smtp_server = "example.com"
          # email.smtp_port = 587
          # email.mail_from_domain = "mailfrom.example.com"

          email.smtp_provider = :unsupported
          email.username = "email@example.com"
          email.password = "hunter2"
        end
      end
    end
  end

  def test_notify_with_email_and_gmail_custom_provider
    Wuphf.configure do |config|
      config.register_notifier(:email) do |email|
        # email.smtp_server = "example.com"
        # email.smtp_port = 587
        # email.mail_from_domain = "mailfrom.example.com"

        email.smtp_provider = :gmail
        email.username = "email@example.com"
        email.password = "hunter2"
      end
    end

    mock_smtp = mock("smtp")
    mock_smtp.expects(:enable_starttls)
    mock_smtp.expects(:open_timeout=).with(5)
    mock_smtp.expects(:read_timeout=).with(5)
    mock_smtp.expects(:send_message).with(
      "Subject: subject\n\nbody",
      "from-email@example.com",
      "to-email@example.com",
    )
    mock_smtp.expects(:start).with(
      "gmail.com",
      "email@example.com",
      "hunter2",
      :login,
    ).yields(mock_smtp)

    Net::SMTP.expects(:new).with("smtp.gmail.com", 587).returns(mock_smtp)

    assert(Wuphf.notify(
      :email,
      {
        body: "body",
        subject: "subject",
        from_email: "from-email@example.com",
        to_email: "to-email@example.com",
      }
    ))
  end

  def test_notify_with_email
    Wuphf.configure do |config|
      config.register_notifier(:email) do |email|
        email.smtp_server = "example.com"
        email.smtp_port = 587
        email.mail_from_domain = "mailfrom.example.com"
        email.username = "email@example.com"
        email.password = "hunter2"
      end
    end

    mock_smtp = mock("smtp")
    mock_smtp.expects(:enable_starttls)
    mock_smtp.expects(:open_timeout=).with(5)
    mock_smtp.expects(:read_timeout=).with(5)
    mock_smtp.expects(:send_message).with(
      "Subject: subject\n\nbody",
      "from-email@example.com",
      "to-email@example.com",
    )
    mock_smtp.expects(:start).with(
      "mailfrom.example.com",
      "email@example.com",
      "hunter2",
      :login,
    ).yields(mock_smtp)

    Net::SMTP.expects(:new).with("example.com", 587).returns(mock_smtp)

    assert(Wuphf.notify(
      :email,
      {
        body: "body",
        subject: "subject",
        from_email: "from-email@example.com",
        to_email: "to-email@example.com",
      }
    ))
  end
end
