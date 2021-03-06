require 'spec_helper'

describe Dome do
  let(:account_dir) { 'deirdre-dev' }
  let(:environment_dir) { 'qa' }
  let(:environment) { Dome::Environment.new([account_dir, environment_dir]) }
  let(:secrets) { Dome::Secrets.new(environment) }

  # to prevent a validation error
  let(:itv_yaml_path) { 'spec/fixtures/itv.yaml' }
  before(:each) { allow(secrets.settings).to receive(:itv_yaml_path) { itv_yaml_path } }

  context 'if config is missing from itv.yaml' do
    context 'outputs a debug message to STDOUT' do
      it 'when missing the parent key dome' do
        allow(secrets.settings).to receive(:load_yaml).and_return({})
        expect { secrets.dome_config }.to output.to_stdout
      end

      it 'when missing the sub-key hiera_keys' do
        yaml = { 'dome' => { 'foo' => 'bar' } }
        allow(secrets.settings).to receive(:load_yaml).and_return(yaml)
        expect { secrets.hiera_keys_config }.to output.to_stdout
      end

      it 'when missing the sub-key certs' do
        yaml = { 'dome' => { 'foo' => 'bar' } }
        allow(secrets.settings).to receive(:load_yaml).and_return(yaml)
        expect { secrets.certs_config }.to output.to_stdout
      end
    end

    it 'does not set secret environment variables' do
      allow(secrets.settings).to receive(:load_yaml).and_return({})
      expect(secrets.hiera).not_to receive(:secret_env_vars)
      secrets.secret_env_vars
    end

    it 'does not extract certificates' do
      allow(secrets.settings).to receive(:load_yaml).and_return({})
      expect(secrets.hiera).not_to receive(:extract_certs)
      secrets.extract_certs
    end

    xit 'only warns you once about missing parent key dome when performing a plan' do
      # TODO
    end
  end

  context 'with valid config' do
    it 'sets secret environment variables' do
      yaml = { 'dome' => { 'hiera_keys' => { 'artifactory_password' => 'artifactory::root-readonly::password' } } }
      allow(secrets.settings).to receive(:load_yaml).and_return(yaml)
      expect(secrets.hiera).to receive(:secret_env_vars)
      secrets.secret_env_vars
    end

    it 'extracts certificates' do
      yaml = { 'dome' => { 'certs' => { 'id_rsa' => 'aws::ssh_privkey_content' } } }
      allow(secrets.settings).to receive(:load_yaml).and_return(yaml)
      expect(secrets.hiera).to receive(:extract_certs)
      secrets.extract_certs
    end
  end
end
