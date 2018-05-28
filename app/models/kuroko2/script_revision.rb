class Kuroko2::ScriptRevision < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition
  belongs_to :user, optional: true

  def html_diff(previous)
    Diffy::Diff.new(previous.try(:script), self.script, context: 3).to_s(:html).html_safe
  end
end
