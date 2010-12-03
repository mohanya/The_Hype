DEFAULT_SETTINGS = YAML.load_file(File.join(RAILS_ROOT, 'config', 'default_settings.yml'))
HYPE_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/hype_config.yml")[RAILS_ENV]
