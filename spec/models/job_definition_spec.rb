require 'rails_helper'

describe Kuroko2::JobDefinition do
  let!(:definition) { create(:job_definition_with_instances) }

  describe '#destroy' do
    subject { definition.destroy }

    context 'token dependency' do
      context 'without token' do
        before { Kuroko2::Token.destroy_all }

        it { is_expected.to be_truthy }
      end

      context 'with token' do
        it { is_expected.to be_falsey }
      end
    end

    context 'schedules dependency' do
      before do
        Kuroko2::Token.destroy_all
        definition.job_schedules.create(cron: '0 * * * *')
      end

      it do
        is_expected.to be_truthy
        expect(Kuroko2::JobSchedule.all.size).to be_zero
      end
    end
  end

  describe "#proceed_multi_instance?" do
    let(:prevent_multi) { 1 }
    let!(:definition) do
      create(
        :job_definition_with_instances,
        prevent_multi: prevent_multi,
      )
    end

    subject { definition.proceed_multi_instance? }

    context 'prevent_multi is default (working, failure)' do
      context "the token's status is working" do
        it { is_expected.to be_falsey }
      end

      context "the token's status is failure" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FAILURE)
        end
        it { is_expected.to be_falsey }
      end

      context "the token's status is finished" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FINISHED)
        end
        it { is_expected.to be_truthy }
      end
    end

    context 'prevent_multi is only working' do
      let(:prevent_multi) { 2 }

      context "the token's status is working" do
        it { is_expected.to be_falsey }
      end

      context "the token's status is failure" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FAILURE)
        end
        it { is_expected.to be_truthy }
      end

      context "the token's status is finished" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FINISHED)
        end
        it { is_expected.to be_truthy }
      end
    end

    context 'prevent_multi is only failure' do
      let(:prevent_multi) { 3 }

      context "the token's status is working" do
        it { is_expected.to be_truthy }
      end

      context "the token's status is failure" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FAILURE)
        end
        it { is_expected.to be_falsey }
      end

      context "the token's status is finished" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FINISHED)
        end
        it { is_expected.to be_truthy }
      end
    end

    context 'prevent_multi is only failure' do
      let(:prevent_multi) { 3 }

      context "the token's status is working" do
        it { is_expected.to be_truthy }
      end

      context "the token's status is failure" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FAILURE)
        end
        it { is_expected.to be_falsey }
      end

      context "the token's status is finished" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FINISHED)
        end
        it { is_expected.to be_truthy }
      end
    end

    context 'prevent_multi disabled' do
      let(:prevent_multi) { 0 }

      context "the token's status is working" do
        it { is_expected.to be_truthy }
      end

      context "the token's status is failure" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FAILURE)
        end
        it { is_expected.to be_truthy }
      end

      context "the token's status is finished" do
        before do
          Kuroko2::Token.where(job_definition_id: definition.id).
            update_all(status: Kuroko2::Token::FINISHED)
        end
        it { is_expected.to be_truthy }
      end
    end
  end
end
