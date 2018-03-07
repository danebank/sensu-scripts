# generateSwitchChecks.rb
#
# Script used to generate Sensu Check config files
# for all switches based on array
#
# James Davis - 7/3/2018
require 'json'
require 'fileutils'

# global variables
$saveDirectory = '/etc/sensu/conf.d/switches/'

# functions
def printSensuCheck(hostname, address, subscription)
  _filename = $saveDirectory + 'check-ping-' + hostname + '.json'
  File.open(_filename, "w") do |output|
    output.puts "{
      \"checks\": {
        \"check-ping-#{hostname}\": {
          \"command\": \"/opt/sensu/embedded/bin/check-ping.rb -h #{address} -c 5\",
          \"interval\": 30,
          \"standalone\": true,
          \"source\": \"#{hostname}\",
          \"subscibers\": \"#{subscription}\",
          \"handler\": \"notify\"
        }
      }
    }"
  end
end

def printSensuMetric(hostname, address, subscription)
  _filename = $saveDirectory + 'metrics-ping-' + hostname + '.json'
  File.open(_filename, "w") do |output|
    output.puts "{
      \"checks\": {
        \"metrics-ping-#{hostname}\": {
          \"type\": \"metric\",
          \"command\": \"/opt/sensu/embedded/bin/metrics-ping.rb -h #{address} -s #{hostname}\",
          \"interval\": 60,
          \"standalone\": true,
          \"source\": \"#{hostname}\",
          \"subscibers\": \"#{subscription}\",
          \"handler\": \"default\"
        }
      }
    }"
  end
end

# main program
FileUtils.rm_rf($saveDirectory)
FileUtils.mkdir_p($saveDirectory)

file = File.read('sensu-clients.json')
clients_hash = JSON.parse(file)

clients_hash['clients'].each do |name, clientdetails|
  _hostname = ""
  _address = ""
  _subscription = ""
  clientdetails.each do |key, value|
    if key == "hostname"
      _hostname = value
    end
    if key == "address"
      _address = value
    end
    if key == "subscription"
      _subscription = value
    end
  end
  printSensuCheck(_hostname, _address, _subscription)
  printSensuMetric(_hostname, _address, _subscription)
end

