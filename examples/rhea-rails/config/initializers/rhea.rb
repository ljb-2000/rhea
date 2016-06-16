require 'rhea'

Rhea.configure do |config|
  config.kube_api = {
    options: {
      # ssl_options: {
      #   client_key: OpenSSL::PKey::RSA.new(Rails.root.join(ENV['KEYS_DIRECTORY'], 'apiserver-key.pem').read),
      #   client_cert: OpenSSL::X509::Certificate.new(Rails.root.join(ENV['KEYS_DIRECTORY'], 'apiserver.pem').read),
      #   ca_file: Rails.root.join(ENV['KEYS_DIRECTORY'], 'ca.pem').to_s,
      #   verify_ssl: OpenSSL::SSL::VERIFY_PEER
      # }
    },
    url: ENV['KUBE_API_URL'] || 'http://localhost:8080/api/'
  }
  config.default_image = 'hello-world:latest'
end
