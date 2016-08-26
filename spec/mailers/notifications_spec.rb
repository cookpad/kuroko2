require 'rails_helper'

describe Kuroko2::Notifications do
  let(:instance) { create(:job_definition_with_instances, name: job_name).job_instances.first }
  let(:definition) { instance.job_definition }
  let(:admins) { definition.admins }
  let(:job_name) { 'My Job' }

  describe 'job_failure' do
    let(:mail) { Kuroko2::Notifications.job_failure(instance) }

    it 'renders the headers' do
      expect(mail.subject).to eq "[CRITICAL] Failed to execute '#{job_name}' on kuroko"
      expect(mail.to).to eq(admins.map(&:email))
      expect(mail.from).to eq(['no-reply@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Name: #{job_name}")
    end
  end

  describe 'job_failure' do
    let(:mail) { Kuroko2::Notifications.remind_failure(instance) }

    before {
      instance.error_at = 2.days.ago
    }

    it 'renders the headers' do
      expect(mail.subject).to eq "[WARN] '#{job_name}' is still in ERROR state"
      expect(mail.to).to eq(admins.map(&:email))
      expect(mail.from).to eq(['no-reply@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Name: #{job_name}")
    end
  end

  describe 'notify_long_elapsed_time' do
    let(:mail) { Kuroko2::Notifications.notify_long_elapsed_time(instance) }

    it 'renders the headers' do
      expect(mail.subject).to eq "[WARN] The running time is longer than expected '#{definition.name}' on kuroko"
      expect(mail.to).to eq(admins.map(&:email))
      expect(mail.from).to eq(['no-reply@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Name: #{job_name}")
    end
  end
end
