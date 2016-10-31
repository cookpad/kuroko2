require 'rails_helper'

module Kuroko2::Workflow
  describe Notifier::Mail do
    let(:job_name) { 'MyJob' }

    let(:instance) do
      create(:job_definition_with_instances, name: job_name).job_instances.first
    end

    let(:notifier) { Notifier::Mail.new(instance) }

    before do
      instance.logs.info('start!')
      ActionMailer::Base.deliveries.clear
    end

    describe '#notify_cancellation' do
      context 'with notify_cancellation is true' do
        before do
          instance.job_definition.notify_cancellation = true
          instance.save!
        end

        it 'sends cancellation mesasge' do
          expect { notifier.notify_cancellation }.to change {
            ActionMailer::Base.deliveries.size
          }.from(0).to(1)
        end
      end

      context 'with notify_cancellation is false' do
        before do
          instance.job_definition.notify_cancellation = false
          instance.save!
        end

        it 'sends cancellation mesasge' do
          expect { notifier.notify_cancellation }.not_to change {
            ActionMailer::Base.deliveries.size
          }
        end
      end
    end

    describe '#notify_failure' do
      it 'sends failure mesasge' do
        expect { notifier.notify_failure }.to change {
          ActionMailer::Base.deliveries.size
        }.from(0).to(1)
      end
    end

    describe '#notify_critical' do
      it 'sends critical mesasge' do
        expect { notifier.notify_critical }.to change {
          ActionMailer::Base.deliveries.size
        }.from(0).to(1)
      end
    end

    describe '#notify_finished' do
      it 'does not send mail' do
        expect { notifier.notify_finished }.not_to change {
          ActionMailer::Base.deliveries.size
        }
      end
    end

    describe '#notify_long_elapsed_time' do
      it 'sends warning mesasge' do
        expect { notifier.notify_long_elapsed_time }.to change {
          ActionMailer::Base.deliveries.size
        }.from(0).to(1)
      end
    end

    describe '#notify_retring' do
      it 'does not send mail' do
        expect { notifier.notify_retring }.not_to change {
          ActionMailer::Base.deliveries.size
        }
      end
    end

    describe '#notify_skipping' do
      it 'does not send mail' do
        expect { notifier.notify_retring }.not_to change {
          ActionMailer::Base.deliveries.size
        }
      end
    end

    describe '#notify_launch' do
      it 'does not send mail' do
        expect { notifier.notify_launch }.not_to change {
          ActionMailer::Base.deliveries.size
        }
      end
    end
  end
end
