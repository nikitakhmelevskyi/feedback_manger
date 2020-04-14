require 'rails_helper'

RSpec.describe FeedbackContract do
  subject { FeedbackContract.new.call(params) }

  let(:experience) { create(:experience) }
  let(:question) { create(:question, experience: experience) }
  let(:user_ip) { Faker::Internet.ip_v4_address }

  let(:question_answer) { Faker::Lorem.sentence(word_count: 3) }
  let(:rating) { [*1..5].sample }

  let(:params) do
    {
      experience: experience,
      user_ip: user_ip,
      rating: rating,
      responses: [
        {
          question_id: question.id,
          answer: question_answer
        }
      ]
    }
  end

  context 'success' do
    it 'returns successful result' do
      expect(subject.success?).to be_truthy
    end
  end

  context 'when feedback with given ip exists' do
    let!(:another_feedback) { Feedback.create(experience: experience, user_ip: user_ip, rating: 3) }

    it 'returns unsuccessful result' do
      expect(subject.success?).to be_falsey
    end

    it 'contains error related to the user ip param' do
      expect(subject.errors[:user_ip]).to include('this user has already left a feedback for this experience')
    end
  end
end
