# frozen_string_literal: true

module Sidekiq
  module Sequence
    module Perform
      def perform(id, *args)
        @record = Record.find(id)
        @data = @record.data.with_indifferent_access

        super(*args)

        # Increment the step and update data attribute.
        @record.increment(:current_step)
        @record.data = @data
        @record.save!

        # Perform the next in sequence.
        if ::Rails.version.to_f >= 6.0
          self.class.module_parent.perform_step @record.current_step, @record.id
        else
          self.class.parent.perform_step @record.current_step, @record.id
        end
      end
    end
  end
end
