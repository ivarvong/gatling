defmodule Mix.Tasks.Gatling.Load do
  use Mix.Task

  import Gatling.Bash
  import Gatling.Utilities

  @moduledoc """
    Create a git repository for your mix project.
    The `project_name` must match `:app` in your mix.exs
  """

  @shortdoc "Create a git repository or your mix project"

  @type project_name :: binary()

  @spec run([project_name]) :: nil
  def run([]) do
    project = Mix.Shell.IO.prompt("Please enter a project name:")
    load(project)
  end

  def run([project]) do
    load(project)
  end

  @spec load([project_name]) :: nil
  @doc """
  Create an empty git repository of the given project

  The repository contains a `post-update` hook that triggers the hot upgrade of future git pushes
  """
  def load(project) do
    build_dir = build_dir(project)
    if File.exists?(build_dir) do
      log(~s(#{build_dir} already exists))
    else
      File.mkdir_p!(build_dir)
      bash("git", ["init", build_dir], [])
      bash("git", ~w[config receive.denyCurrentBranch updateInstead], cd: build_dir)
      install_post_receive_hook(project)
    end
    nil
  end

  defp install_post_receive_hook(project) do
    file = git_hook_template(project_name: project)
    path = git_hook_path(project)

    File.write!(path, file)
    File.chmod!(path, 0o777)
  end

end
