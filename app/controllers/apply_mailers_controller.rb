module ApplyMailersController
  def preview
    ActiveRecord::Base.transaction do
      # We render a custom email preview header. The `render_preview_wrapper` method in the `mail-notify gem` is responsible
      # for rendering the preview. https://github.com/dxw/mail-notify/blob/b1fedbafa209d58e4e03d93082ef6d5b8fc273de/lib/mail/notify/mailers_controller.rb#L30
      # The call below tells this gem where to find our custom template.
      prepend_view_path('spec/mailers/previews')

      super
      raise ActiveRecord::Rollback
    end
  end
end
