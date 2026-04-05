# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Resumes::ExtractText do
  describe '#call' do
    context 'when resume has no attached file' do
      it 'raises ArgumentError' do
        resume = create(:resume)

        expect { described_class.new(resume).call }
          .to raise_error(ArgumentError, /no attached file/)
      end
    end

    context 'when resume has an attached PDF' do
      it 'returns extracted text from the PDF' do
        resume = create(:resume, :with_file)
        reader = instance_double(PDF::Reader)
        page = instance_double(PDF::Reader::Page, text: 'Extracted resume text')

        allow(PDF::Reader).to receive(:new).and_return(reader)
        allow(reader).to receive(:pages).and_return([page])

        result = described_class.new(resume).call

        expect(result).to eq('Extracted resume text')
      end

      it 'joins text from multiple pages' do
        resume = create(:resume, :with_file)
        reader = instance_double(PDF::Reader)
        page1 = instance_double(PDF::Reader::Page, text: 'Page one')
        page2 = instance_double(PDF::Reader::Page, text: 'Page two')

        allow(PDF::Reader).to receive(:new).and_return(reader)
        allow(reader).to receive(:pages).and_return([page1, page2])

        result = described_class.new(resume).call

        expect(result).to eq("Page one\nPage two")
      end
    end
  end
end
