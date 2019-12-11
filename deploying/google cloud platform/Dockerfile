FROM julia:1.3

# Unlike the dockerfile in the examples folder, this mimics the typical flow for a project that
# uses Joseki. 

# Needed for GCP
ENV JULIA_DEPOT_PATH=/depot

# First, we add the Project.toml and Manifest.toml.
ADD *.toml /joseki_on_gcp/
WORKDIR /joseki_on_gcp

# Install dependencies
RUN julia --project -e 'using Pkg; pkg"instantiate"'

# Add source files
ADD *.jl /joseki_on_gcp/

# Briefly run the server to trigger precompilation
RUN julia --project warmup.jl

# Make sure root doesn't own the Julia depot
RUN useradd -ms /bin/bash myuser
RUN chown -R myuser:myuser /depot
USER myuser

CMD julia -e 'using Pkg; pkg"activate ."; include("server_definition.jl"); HTTP.serve(router, "0.0.0.0", port)'
