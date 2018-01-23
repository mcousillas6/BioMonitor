# Cloud-Backend
This repo contains the code related to the cloud backend that is in charge of storing the data on the cloud and provide remote access to monitoring the status of the experiments.
It will:
  * Send and receive data and instructions from and to the local backend via web sockets.
  * Expose a REST API for the Monitoring UI.
  * Send live updates to the Monitoring UI via web-sockets.

## Dependencies
The following dependencies are used on this project:
  * `Elixir 1.4.2`.
  * `Phoenix 1.2` as our web framework.
  * `Credo` for style code checking.
  * `Faker` for faking data for testing.

## Instalation
To run the BioMonitor follow these steps:
  1. Clone the repo.
  2. Installs the dependencies using `mix deps.get`
  3. Create the database running `mix ecto.create` you need `PostgreSQL` installed and running on your machine.
  4. Run the server using `mix phoenix.server`

## API docs
For more detailed usage, check out it [here](https://openfermentor.github.io/Cloud-Backend/)

## Contributing
please refer to our [contributing guide](https://github.com/OpenFermentor/Guidelines/blob/master/contributing_guide.md) for more information.
