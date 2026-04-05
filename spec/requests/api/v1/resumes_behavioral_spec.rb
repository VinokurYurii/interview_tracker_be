# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Resumes', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/resumes' do
    it 'returns only resumes belonging to the current user' do
      create_list(:resume, 2, user: user)
      create(:resume)

      get '/api/resumes', headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.length).to eq(2)
    end
  end

  describe 'POST /api/resumes' do
    it 'creates a resume with name only' do
      expect {
        post '/api/resumes', params: { resume: { name: 'Backend CV' } }, headers: headers, as: :json
      }.to change(Resume, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['name']).to eq('Backend CV')
      expect(data['file_url']).to be_nil
    end

    it 'creates a resume with file' do
      file = Rack::Test::UploadedFile.new(
        StringIO.new('%PDF-1.4 fake'),
        'application/pdf',
        true,
        original_filename: 'cv.pdf'
      )

      expect {
        post '/api/resumes', params: { resume: { name: 'With File', file: file } }, headers: headers
      }.to change(Resume, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['file_url']).to be_present
    end

    it 'rejects duplicate name for the same user' do
      create(:resume, name: 'Backend CV', user: user)

      post '/api/resumes', params: { resume: { name: 'Backend CV' } }, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'rejects non-PDF file' do
      file = Rack::Test::UploadedFile.new(
        StringIO.new('not a pdf'),
        'text/plain',
        true,
        original_filename: 'doc.txt'
      )

      post '/api/resumes', params: { resume: { name: 'Bad File', file: file } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'GET /api/resumes/:id' do
    it 'returns the resume with file_url' do
      resume = create(:resume, :with_file, user: user)

      get "/api/resumes/#{resume.id}", headers: headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['name']).to eq(resume.name)
      expect(data['file_url']).to be_present
    end

    it 'returns 403 for another user\'s resume' do
      other_resume = create(:resume)

      get "/api/resumes/#{other_resume.id}", headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 404 for non-existent resume' do
      get '/api/resumes/0', headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/resumes/:id' do
    it 'updates the resume name' do
      resume = create(:resume, user: user)

      patch "/api/resumes/#{resume.id}", params: { resume: { name: 'Updated CV' } },
                                         headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['name']).to eq('Updated CV')
    end

    it 'replaces the file' do
      resume = create(:resume, :with_file, user: user)
      new_file = Rack::Test::UploadedFile.new(
        StringIO.new('%PDF-1.4 new content'),
        'application/pdf',
        true,
        original_filename: 'new_cv.pdf'
      )

      patch "/api/resumes/#{resume.id}", params: { resume: { file: new_file } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(resume.reload.file).to be_attached
    end

    it 'returns 403 for another user\'s resume' do
      other_resume = create(:resume)

      patch "/api/resumes/#{other_resume.id}", params: { resume: { name: 'Hack' } },
                                               headers: headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/resumes/:id' do
    it 'destroys the resume when no linked positions' do
      resume = create(:resume, user: user)

      expect {
        delete "/api/resumes/#{resume.id}", headers: headers
      }.to change(Resume, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'purges file but keeps record when has linked positions' do
      resume = create(:resume, :with_file, user: user)
      create(:position, resume: resume, user: user)

      expect {
        delete "/api/resumes/#{resume.id}", headers: headers
      }.not_to change(Resume, :count)

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['warning']).to be_present
      expect(resume.reload.file).not_to be_attached
    end

    it 'returns 403 for another user\'s resume' do
      other_resume = create(:resume)

      delete "/api/resumes/#{other_resume.id}", headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/resumes/:id/generate_analysis' do
    it 'returns 202 and enqueues job when resume is analyzable' do
      resume = create(:resume, :with_file, user: user)
      position = create(:position, user: user, resume: resume)
      create(:interview_stage, position: position)

      expect {
        post "/api/resumes/#{resume.id}/generate_analysis", headers: headers
      }.to have_enqueued_job(GenerateResumeAnalysisJob)

      expect(response).to have_http_status(:accepted)
      data = JSON.parse(response.body)
      expect(data['status']).to eq('pending')
    end

    it 'returns 422 when resume has no file' do
      resume = create(:resume, user: user)
      position = create(:position, user: user, resume: resume)
      create(:interview_stage, position: position)

      post "/api/resumes/#{resume.id}/generate_analysis", headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      data = JSON.parse(response.body)
      expect(data['error']).to include('no attached file')
    end

    it 'returns 422 when resume has no positions with stages' do
      resume = create(:resume, :with_file, user: user)

      post "/api/resumes/#{resume.id}/generate_analysis", headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      data = JSON.parse(response.body)
      expect(data['error']).to include('no positions with interview stages')
    end

    it 'returns 422 when analysis is already in progress' do
      resume = create(:resume, :with_file, user: user)
      position = create(:position, user: user, resume: resume)
      create(:interview_stage, position: position)
      create(:resume_analysis, resume: resume, status: :pending)

      post "/api/resumes/#{resume.id}/generate_analysis", headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      data = JSON.parse(response.body)
      expect(data['error']).to include('already in progress')
    end

    it 'returns 403 for another user\'s resume' do
      other_resume = create(:resume, :with_file)

      post "/api/resumes/#{other_resume.id}/generate_analysis", headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end
end
