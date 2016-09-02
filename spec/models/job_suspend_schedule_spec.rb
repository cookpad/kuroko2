require 'rails_helper'

describe Kuroko2::JobSuspendSchedule do
  describe '#valid?' do
    it 'accepts only CRON notation' do
      expect(Kuroko2::JobSuspendSchedule.new(cron: '* * * * *')).to be_valid
      expect(Kuroko2::JobSuspendSchedule.new(cron: '1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,5-6/7 1,2-3,*,*/4,1-3/5')).to be_valid
      expect(Kuroko2::JobSuspendSchedule.new(cron: '* * * *')).not_to be_valid
    end

    it 'accepts only valid CRON notation' do
      expect(Kuroko2::JobSuspendSchedule.new(cron: '5-0 * * * *')).not_to be_valid
    end
  end

  describe '#suspend_times' do
    let(:suspend_schedule) { create(:job_suspend_schedule, cron: '* 10 * * *') }
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
