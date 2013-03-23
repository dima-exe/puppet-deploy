#
class deploy::params(
  $deploy_to = '/u/apps',
) {
  Deploy::Application <| |> -> Deploy::Rails <| |>
}
