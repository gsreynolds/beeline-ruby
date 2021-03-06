Honeycomb.configure do |config|
  config.write_key = "{WRITE_KEY}"
  config.dataset = "rails"
  config.service_name = "rails_development"
  config.client = Libhoney::LogClient.new
  config.notification_events = %w[
      sql.active_record
      render_template.action_view
      render_partial.action_view
      render_collection.action_view
      process_action.action_controller
      send_file.action_controller
      send_data.action_controller
      deliver.action_mailer
    ].freeze
end
