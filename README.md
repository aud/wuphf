Note: WIP. Not to be used.

Simple Ruby library that acts as a generic notifier of events.

# Supported services
1. Email - this requires a SMTP server. Gmail works: https://kinsta.com/blog/gmail-smtp-server/

# Future services considered
1. Text or calls (Twilio)
2. Webhook (more generic extensibility)

# Usage
```rb
require "wuphf"

Wuphf.configure do |config|
  config.register_notifier(:email) do |email|
    email.smtp_server = "smtp.gmail.com"
    email.mail_from_domain = "gmail.com"
    email.smtp_port = 587
    email.username = "email@example.com"
    email.password = "hunter2"
  end

  config.logger = Rails.logger # optional, defaults to stdout
  config.debug = true # optional, enables debug logging
end

Wuphf.notify(:email,
  body: "body",
  subject: "subject",
  from_email: "from-email@example.com",
  to_email: "to-email@example.com",
)
```
