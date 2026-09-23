{
  description = "VS Code-style sidebar for herdr: file explorer + source control in one pane";

  inputs = {
    herdr-sidebar.url = "path:./plugins/herdr-sidebar";
  };

  outputs = { self, herdr-sidebar }: herdr-sidebar.outputs;
}
