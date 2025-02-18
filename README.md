# gramine-walle

## Build and Run

# Build the Docker image
docker build -t gramine .

# View SGX measurements
docker run --rm gramine

# Build the SGX version
docker compose run --rm gramine make sgx

# Run the application in SGX
docker compose run --rm gramine gramine-sgx nodejs
