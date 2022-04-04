Note: WIP. Not to be used.

Simple Ruby library that acts as a generic notifier of events.

# Supported services
1. Email, this requires a SMTP server.
   [Gmail](https://support.google.com/mail/answer/7126229?hl=en#zippy=%2Ci-cant-sign-in-to-my-email-client%2Cstep-change-smtp-other-settings-in-your-email-client) works nicely for small volume (<= 500 per day).
2. Twilio SMS, requires active Twilio account.

# Future services considered
1. Phone calls
2. Webhook (more generic extensibility)

# Usage
```rb
require "wuphf"

Wuphf.configure do |config|
  config.register_notifier(:email) do |email|
    # Custom SMTP server
    email.smtp_provider = :custom
    email.smtp_server = "smtp.gmail.com"
    email.mail_from_domain = "gmail.com"
    email.smtp_port = 587
    email.username = "email@example.com"
    email.password = "hunter2"

    # Or you can specify a supported provider (gmail only currently supported)
    email.smtp_provider = :gmail
    email.username = "email@example.com"
    # If you're using the gmail provider and your account has 2fa enabled, you
    # will need to create a gmail app password.
    email.password = "hunter2"
  end

  config.register_notifier(:twilio_sms) do |twilio_sms|
    twilio_sms.account_sid = "ACdc99e45633f6be1c2c59a8f7ea3bbaad"
    twilio_sms.auth_token = "yyyyyyyyyyyyyyyyyyyyyyyyy"
  end

  config.logger = Rails.logger # optional, defaults to stdout
  config.debug_mode = true # optional, enables debug logging
end

# Email
Wuphf.notify(
  :email,
  {
    body: "body",
    subject: "subject",
    from_email: "from-email@example.com",
    to_email: "to-email@example.com",
  }
)

# Twilio SMS
Wuphf.notify(
  :twilio_sms,
  {
    from: "+15551234567",
    to: "+15555555555",
    body: "Hello world",
  }
)
```
