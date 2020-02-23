defmodule Mix.Tasks.Publish do
  use Mix.Task

  def run([]) do
    date = Date.utc_today() |> Date.to_iso8601()
    run(["#{date}.1"])
  end

  @shortdoc "Publish a new version of the blog"
  def run([tag]) do
    IO.puts "publishing #{tag}"
    {_, 0} = System.cmd("docker", ["build", "-t","hqmq/blog:#{tag}","."])
    {_, 0} = System.cmd("docker", ["tag","hqmq/blog:#{tag}","hqmq/blog:latest"])
    {_, 0} = System.cmd("docker", ["push","hqmq/blog:#{tag}"])
    {_, 0} = System.cmd("docker", ["push","hqmq/blog:latest"])
  end
end
