class StepsController < ApplicationController
  helper FormElementsHelper

  def index
    @prisoner_step = PrisonerStep.new
    render :prisoner
  end

  def create
    select_step
  end

private

  def available_slots
    @prisoner_step.prison.available_slots
  end
  helper_method :available_slots

  def select_step
    if prisoner_step_needed?
      render :prisoner
    elsif visitors_step_needed?
      render :visitors
    elsif slots_step_needed?
      render :slots
    end
  end

  def prisoner_step_needed?
    @prisoner_step, needed = load_step(PrisonerStep, :prisoner_step)
    needed
  end

  def visitors_step_needed?
    @visitors_step, needed = load_step(VisitorsStep, :visitors_step)
    needed
  end

  def slots_step_needed?
    @slots_step, needed = load_step(SlotsStep, :slots_step)
    needed
  end

  def load_step(klass, name)
    if params.key?(name)
      step = klass.new(params[name])
      needed = !step.valid?
    else
      step = klass.new
      needed = true
    end

    [step, needed]
  end
end
