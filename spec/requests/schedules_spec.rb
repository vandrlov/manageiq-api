RSpec.describe "Schedules API" do
  let!(:sched) { FactoryBot.create(:miq_schedule) }
  describe 'GET /api/schedules' do
    context 'without an appropriate role' do
      it 'does not list Schedules' do
        api_basic_authorize
        get(api_schedules_url)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with an appropriate role' do
      before { api_basic_authorize collection_action_identifier(:schedules, :read, :get) }

      it 'lists schedules' do
        get(api_schedules_url)

        expected = {
          'count'     => 1,
          'subcount'  => 1,
          'pages'     => 1,
          'name'      => 'schedules',
          'resources' => [
            "href" => api_schedule_url(nil, sched)
          ]
        }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(expected)
      end
    end
  end

  describe 'GET /api/schedules/:id' do
    context 'without an appropriate role' do
      it 'does not list Schedule' do
        api_basic_authorize
        get(api_schedule_url(nil, sched))
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with an appropriate role' do
      before { api_basic_authorize action_identifier(:schedules, :read, :resource_actions, :get) }

      it 'show Schedule' do
        get(api_schedule_url(nil, sched))

        expected = {
          'id'            => sched.id.to_s,
          'resource_type' => "MiqReport"
        }

        expect(response).to have_http_status(:ok)
        binding.pry
        expect(response.parsed_body).to include(expected)
      end
    end
  end

  describe 'POST /api/schedules' do
    it 'can create schedules' do
      api_basic_authorize collection_action_identifier(:schedules, :create)
      post(api_schedules_url, :params => gen_request(:create, {
        'name'          => "foo",
        'description'   => "test",
        'resource_type' => "MiqReport",
        'run_at'        => {
          'interval'   => {:unit => "once" },
          'start_time' => "2010-07-08T04:10:00Z"
        }
      }))
      expect(response).to have_http_status(:ok)
      binding.pry
      schedule =  MiqSchedule.find(response.parsed_body['results'].first["id"])
      expect(schedule.name).to eq('foo')
    end
  end

  describe 'DELETE /api/schedules/:id' do
    context 'without an appropriate role' do
      it 'cannot delete a schedule' do
        api_basic_authorize
        delete(api_schedule_url(nil, sched))
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with an appropriate role' do
      before { api_basic_authorize action_identifier(:schedules, :delete, :resource_actions, :delete) }

      it 'can delete a schedule by id' do
        delete(api_schedule_url(nil, sched))
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
