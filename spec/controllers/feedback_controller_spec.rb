require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: params }

    let(:experience) { create(:experience) }
    let(:question) { create(:question, experience: experience) }
    let(:user_ip) { Faker::Internet.ip_v4_address }
    let(:question_answer) { Faker::Lorem.sentence(word_count: 3) }
    let(:rating) { [*1..5].sample }

    let(:experience_id) { experience.id }

    let(:params) do
      {
        experience_id: experience_id,
        rating: rating,
        responses: [
          {
            question_id: question.id,
            answer: question_answer
          }
        ]
      }
    end

    before do
      @request.remote_addr = user_ip
    end

    context 'success' do
      let(:expected_json) do

      end
      it { is_expected.to have_http_status :created }

      it 'renders serialized feedback' do
        subject

        response = Response.last
        expect(json_response[:feedback].except(:id, :created_at)).to eq(
          rating: rating,
          experience: {
            id: experience.id,
            name: experience.name,
            avg_rating: experience.avg_rating
          },
          responses: [
            {
              id: response.id,
              answer: response.answer
            }
          ]
        )
      end
    end

    context 'when experience not found' do
      let(:experience_id) { 99999 }

      it { is_expected.to have_http_status :not_found }
    end

    context 'when feedback is invalid due to user ip address' do
      let!(:another_feedback) { Feedback.create(experience: experience, user_ip: user_ip, rating: 3) }

      it { is_expected.to have_http_status :unprocessable_entity }

      it 'contains appropriate errors in response' do
        subject

        expect(json_response[:error][:user_ip]).to eq(['this user has already left a feedback for this experience'])
      end
    end
  end
end
