class HealthcheckController < ApplicationController
  def index
    healthcheck = Healthcheck.new
    status = healthcheck.ok? ? nil : :service_unavailable
    render status: status, json: healthcheck.checks
  end
end
