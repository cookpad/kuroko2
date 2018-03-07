require 'rails_helper'

describe Kuroko2::ExecutionHistoriesController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let!(:histories) { create_list(:execution_history, 3) }

  describe '#index' do
    subject! { get :index }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')

      expect(assigns(:histories)).to match_array histories
    end

    context 'with valid queue' do
      subject! { get :index, params: { queue: '@default' } }

      it do
        expect(assigns(:histories)).to match_array histories
      end
    end

    context 'with unknown queue' do
      subject! { get :index, params: { queue: 'unknown' } }

      it do
        expect(assigns(:histories)).to be_empty
      end
    end

    context 'with valid hostname' do
      subject! { get :index, params: { hostname: 'rspec' } }

      it do
        expect(assigns(:histories)).to match_array histories
      end
    end

    context 'with unknown hostname' do
      subject! { get :index, params: { hostname: 'unknown' } }

      it do
        expect(assigns(:histories)).to be_empty
      end
    end
  end

  describe '#timeline' do
    subject! { get :timeline }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('timeline')
    end
  end

  describe '#dataset' do
    subject! { get :dataset, xhr: true }

    it do
      expect(response).to have_http_status(:ok)

      expect(assigns(:histories)).to match_array histories
      expect(assigns(:end_at)).not_to be_nil
      expect(assigns(:start_at)).to eq(assigns(:end_at) - 1.hour)
    end

    context 'with valid queue' do
      subject! { get :dataset, xhr: true, params: { queue: '@default' } }

      it do
        expect(assigns(:histories)).to match_array histories
      end
    end

    context 'with unknown queue' do
      subject! { get :dataset, xhr: true, params: { queue: 'unknown' } }

      it do
        expect(assigns(:histories)).to be_empty
      end
    end

    context 'with valid hostname' do
      subject! { get :dataset, xhr: true, params: { hostname: 'rspec' } }

      it do
        expect(assigns(:histories)).to match_array histories
      end
    end

    context 'with unknown hostname' do
      subject! { get :dataset, xhr: true, params: { hostname: 'unknown' } }

      it do
        expect(assigns(:histories)).to be_empty
      end
    end

    context 'with period' do
      subject! { get :dataset, xhr: true, params: { period: period }}

      context '30 minutes' do
        let(:period) { '30m' }
        it do
          expect(assigns(:histories)).to match_array histories
          expect(assigns(:start_at)).to eq(assigns(:end_at) - 30.minutes)
        end
      end
      context '1 hour' do
        let(:period) { '1h' }
        it do
          expect(assigns(:histories)).to match_array histories
          expect(assigns(:start_at)).to eq(assigns(:end_at) - 1.hour)
        end
      end

      context '1 day' do
        let(:period) { '1d' }
        it do
          expect(assigns(:histories)).to match_array histories
          expect(assigns(:start_at)).to eq(assigns(:end_at) - 1.day)
        end
      end

      context '1 week' do
        let(:period) { '1w' }
        it do
          expect(assigns(:histories)).to match_array histories
          expect(assigns(:start_at)).to eq(assigns(:end_at) - 1.week)
        end
      end
    end

    context 'with end_at' do
      let(:end_at) { Time.current + 5.minute }
      subject! { get :dataset, xhr: true, params: { end_at: end_at } }

      it do
        expect(assigns(:histories)).to match_array histories
        expect(assigns(:end_at).strftime("%d-%m-%Y %H:%M:%S")).to eq end_at.strftime("%d-%m-%Y %H:%M:%S")
      end

      context 'with invalid' do
        let(:end_at) { 'invalid' }

        it do
          expect(assigns(:histories)).to match_array histories
        end
      end
    end

    context 'with start_at' do
      let(:start_at) { 1.hour.ago(Time.current) }
      subject! { get :dataset, xhr: true, params: { start_at: start_at } }

      it do
        expect(assigns(:histories)).to match_array histories
        expect(assigns(:start_at).strftime("%d-%m-%Y %H:%M:%S")).to eq start_at.strftime("%d-%m-%Y %H:%M:%S")
      end

      context 'with invalid' do
        let(:start_at) { 'invalid' }

        it do
          expect(assigns(:histories)).to match_array histories
          expect(assigns(:start_at)).to eq(assigns(:end_at) - 1.hour)
        end
      end
    end
  end
end
