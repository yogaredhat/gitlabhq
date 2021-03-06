# UrlValidator
#
# Custom validator for URLs.
#
# By default, only URLs for the HTTP(S) protocols will be considered valid.
# Provide a `:protocols` option to configure accepted protocols.
#
# Example:
#
#   class User < ActiveRecord::Base
#     validates :personal_url, url: true
#
#     validates :ftp_url, url: { protocols: %w(ftp) }
#
#     validates :git_url, url: { protocols: %w(http https ssh git) }
#   end
#
# This validator can also block urls pointing to localhost or the local network to
# protect against Server-side Request Forgery (SSRF), or check for the right port.
#
# Example:
#   class User < ActiveRecord::Base
#     validates :personal_url, url: { allow_localhost: false, allow_local_network: false}
#
#     validates :web_url, url: { ports: [80, 443] }
#   end
class UrlValidator < ActiveModel::EachValidator
  DEFAULT_PROTOCOLS = %w(http https).freeze

  attr_reader :record

  def validate_each(record, attribute, value)
    @record = record

    if value.present?
      value.strip!
    else
      record.errors.add(attribute, "must be a valid URL")
    end

    Gitlab::UrlBlocker.validate!(value, blocker_args)
  rescue Gitlab::UrlBlocker::BlockedUrlError => e
    record.errors.add(attribute, "is blocked: #{e.message}")
  end

  private

  def default_options
    # By default the validator doesn't block any url based on the ip address
    {
      protocols: DEFAULT_PROTOCOLS,
      ports: [],
      allow_localhost: true,
      allow_local_network: true
    }
  end

  def current_options
    options = self.options.map do |option, value|
      [option, value.is_a?(Proc) ? value.call(record) : value]
    end.to_h

    default_options.merge(options)
  end

  def blocker_args
    current_options.slice(:allow_localhost, :allow_local_network, :protocols, :ports).tap do |args|
      if allow_setting_local_requests?
        args[:allow_localhost] = args[:allow_local_network] = true
      end
    end
  end

  def allow_setting_local_requests?
    ApplicationSetting.current&.allow_local_requests_from_hooks_and_services?
  end
end
