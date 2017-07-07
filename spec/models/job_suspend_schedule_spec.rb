require 'rails_helper'

describe Kuroko2::JobSuspendSchedule do
  let(:launch_schedule) { create(:job_schedule, cron: '* * * * *') }

  describe '#valid?' do
    it 'accepts only CRON notation' do
      expect(Kuroko2::JobSuspendSchedule.new(cron: '0-30 10 * * *', job_definition: launch_schedule.job_definition)).to be_valid
      expect(Kuroko2::JobSuspendSchedule.new(cron: '1,2-3,*/4,5-6/7 1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,1-3/5', job_definition: launch_schedule.job_definition)).to be_valid
      expect(Kuroko2::JobSuspendSchedule.new(cron: '* * * *', job_definition: launch_schedule.job_definition)).not_to be_valid
    end

    it 'accepts only valid CRON notation' do
      expect(Kuroko2::JobSuspendSchedule.new(cron: '5-0 * * * *', job_definition: launch_schedule.job_definition)).not_to be_valid
    end

    context 'when suspend all schedules' do
      let(:launch_schedule) { create(:job_schedule, cron: '5 10 * * 0') }

      it 'does not accept' do
        expect(Kuroko2::JobSuspendSchedule.new(cron: '* * * * 0', job_definition: launch_schedule.job_definition)).not_to be_valid
      end

      context 'when launch schedule has wdays and days' do
        let(:launch_schedule) { create(:job_schedule, cron: '5 10 1 * 1') }

        it 'does not accept' do
          expect(Kuroko2::JobSuspendSchedule.new(cron: '* * 1 * 1', job_definition: launch_schedule.job_definition)).not_to be_valid
        end

        context 'when supend_schedule has only wdays' do
          let(:launch_schedule) { create(:job_schedule, cron: '5 10 1 * 1') }

          it 'accepts' do
            expect(Kuroko2::JobSuspendSchedule.new(cron: '* * * * 1', job_definition: launch_schedule.job_definition)).to be_valid
          end
        end

        context 'when supend_schedule has only days' do
          let(:launch_schedule) { create(:job_schedule, cron: '5 10 1 * 1') }

          it 'accepts' do
            expect(Kuroko2::JobSuspendSchedule.new(cron: '* * 1 * *', job_definition: launch_schedule.job_definition)).to be_valid
          end
        end
      end
    end
  end

  describe '#suspend_times' do
    let(:suspend_schedule) { create(:job_suspend_schedule, cron: '* 10 * * *', job_definition: launch_schedule.job_definition) }
    let(:time_from) { Time.new(2016, 1, 1, 10, 0, 0) }
    let(:time_to) { Time.new(2016, 1, 1, 10, 5, 0) }

    it 'returns suspend times' do
      expect(suspend_schedule.suspend_times(time_from, time_to)).to eq([
        Time.new(2016, 1, 1, 10, 0, 0),
        Time.new(2016, 1, 1, 10, 1, 0),
        Time.new(2016, 1, 1, 10, 2, 0),
        Time.new(2016, 1, 1, 10, 3, 0),
        Time.new(2016, 1, 1, 10, 4, 0),
        Time.new(2016, 1, 1, 10, 5, 0),
      ])
    end
  end
end
